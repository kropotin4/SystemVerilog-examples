# SystemVerilog Examples

Несколько тестовых примеров SystemVerilog кода для симулятора QuestaSim.

Требования для запуска:
1. Установленный и прописанный в PATH QuestaSim.
2. Умение запустить консоль и переместится в нужную папку.
3. Набрать команду "questasim -do work.do"

Для удобного запуска создан work.do файл со всеми нужными командами.

____

## Примеры кода

### Example 1
Простой testbanch (tb) с синхросигналом (clk), сигналом сброса (reset_n) и элементарным
модулем add, реализующим синхронное сложение/вычитание. В tb добавлены два case - один для сложение,
один для вычитания.

### Example 2
Example 1, где в модуле add логика была разбита на комбинатрную (через assign) и
последовательную (те же триггеры) - так, вообще говоря, правильнее, хотя assign это не самый
лучший пример комбинаторного блока (просто частный, и самый простой, случай). В tb добавлены
одна функция и один task для более удобной проверки блока.

____

## Небольшое FAQ

Логику в SystemVerilog можно разделить на последоваетльную и комбинаторную.

### Последовательная логика

Последовательная логика - это все, что связанно с триггерами.

```SystemVerilog
always_ff @(posedge clk) begin
    *** какая-то логика ***         <= объявление триггера
end
```

Важно обратить винмание на "posedge clk" - это значит, что триггер "срабатывает" (меняет значение),
когда clk меняет значение с 0 к 1. Если бы было написано "negedge clk" - было бы наоборот.

Старайтесь делать always_ff минималистичным и избавленным от комбинаторной логики:

```SystemVerilog
always_ff @(posedge clk) begin
    if (condition_1)
        res <= a + b;
    else if (condition_2)
        res <= a - b;               <= плохой пример, всю комбинаторную логику надо бы вынести
    else if (condition_3)
        res <= a * b;
    else
        res <= a / b;
end
```

```SystemVerilog
always_ff @(posedge clk) begin
    if (condition_1)
        res <= res_1;
    else if (condition_2)
        res <= res_2;               <= уже лучше
    else if (condition_3)
        res <= res_3;
    else
        res <= res_4;
end
```

Старайтесь не городить лес из if - не очень красиво, также старайтесь, чтобы каждый always_ff
задавал только одну переменную:

```SystemVerilog
always_ff @(posedge clk) begin
    res1 <= a;
    res2 <= b;                      <= плохо
    res3 <= c;
end
```

```SystemVerilog
always_ff @(posedge clk)
    res1 <= a;

always_ff @(posedge clk)            <= так удобней
    res2 <= b;

always_ff @(posedge clk)
    res3 <= c;
```

### Комбинаторная логика

Комбинаторная логика - это, проще говоря, все логика, где нет синхронизации.

a + b           <= комбинаторная логика

((a + b)*c/d)^2 <= тоже комбинаторная логика

И всякая прочая рассчитываемая муть.

Соответственно, комбинаторная логика пишиться через два блока:

```SystemVerilog
assign res = a + b              <= Удобная форма (без подводных камней) для любых простых выражений
```

Вторая, более общая форма, always_comb блок:

```SystemVerilog
always_comb begin
    *** какая-то логика ***
end
```