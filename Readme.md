# SystemVerilog Examples

Несколько тестовых примеров SystemVerilog кода для симулятора QuestaSim.

Требования для запуска:
1. Установленный и прописанный в PATH QuestaSim.
2. Умение запустить консоль и переместится в нужную папку.
3. Набрать команду "questasim -do work.do"

Для удобного запуска создан work.do файл со всеми нужными командами для Questa.

Кроме того, есть возможность запуска примеров через Make (но для этого, очевидно, должен
быть установлен Make). В главной директории проекта (там же, где находиться Makefile):
* make run-ex1 - запуск первого примера
* make run-ex2 - запуск второго примера
* make run-ex3 - запуск третьего примера
* make clean-all - очистка от мусорных файлов

В каждой папке exampleN также есть make с примерно такими же командами. Чтобы узнать какие команды
есть прямо в консоле (если не работают табы), просто введите "make" и нажмите enter (аналогичным
образом получить справку можно введя команду "make usage").
____

## Примеры кода

### Example 1
Простой testbanch (tb) с синхросигналом (clk), сигналом сброса (reset_n) и элементарным
модулем add, реализующим синхронное сложение/вычитание. В tb добавлены два case - один для сложение,
один для вычитания.

### Example 2
Example 1 + в модуле add логика была разбита на комбинатрную (через assign) и
последовательную (через триггеры) - так, вообще говоря, правильнее.
В tb добавлен пример функции и task-а для более удобной проверки блока.

### Example 3
Это уже интереснее. В Example 3 создан пример очень простого и не очень эффективного АЛУ
(арифметическо-логического устройства). АЛУ в данном варианте совмещен с декодером (довольно редкий
случай, который возможен в низкочастотных процессорах), так что на вход в него подается, вместе
с аргументами, chunk (код команды, который генерируется ассембелером и в котором зашиты ссылки
на регистры, где эти аргументы храняться), в ином же случае подавался бы раздекодированный сигнал.

Кроме того, стоит обатить внимание на параметр N_CYCLE. Если N_CYCLE равен 1, то результат работы
АЛУ кладется на триггеры и отдается в следующем такте. Этим мы разрываем критический путь, который
в ином случае продолжился бы дальше (и мог бы не влезть в частоту работы процессора).
____

## Небольшое FAQ

Логику в SystemVerilog можно разделить на последоваетльную и комбинаторную.

### Комбинаторная логика

Комбинаторная логика - это, проще говоря, вся логика, где нет синхронизации.

a + b           <= комбинаторная логика

((a + b)*c/d)*2 <= тоже комбинаторная логика

И всякая прочая рассчитываемая муть.

Соответственно, комбинаторная логика пишиться через два блока:

```SystemVerilog
assign res = a + b;             <= Удобная форма (без подводных камней) для любых простых выражений
```

Вторая, более общая форма, always_comb блок:

```SystemVerilog
always_comb begin
    *** какая-то логика ***
end
```

С always_comb блоками всегда существует один важный нюанс (которого нет в assign):
вы никогда не должны оставлять в ней неопределенности. Например:

```SystemVerilog
always_comb begin
    if (condition_1) begin
        a = 1;                  <= При условии 1 -> a = 1
    end
    else if (condition_2) begin
        a = 2;                  <= При условии 2 -> a = 2
    end
end
```

Какое значение будет у переменной "а" (в верхнем примере), если два условия не выполняться? Не понятно,
и всем программам, которые будут пытаться интерпретировать этот код, тоже не будет понятно.
Поэтому надо стараться такой код не писать (хотя стоит заметить, что те же программы сразу
сообщат вам о наличии подобных мест в вашем коде).

Как можно было бы избежать этой ситуации:

```SystemVerilog
always_comb begin
    if (condition_1) begin
        a = 1;
    end
    else if (condition_2) begin
        a = 2;
    end
    else begin
        a = 0;                  <= Добавлен else, который сработает в остальных случаях.
    end
end
```

Другой вариант:

```SystemVerilog
always_comb begin
    a = 0;                      <= Этот вариант даже удобнее, задаем значение по-умолчание и
                                   не нужно париться с else в разный условиях.

    if (condition_1) begin
        a = 1;
    end
    else if (condition_2) begin
        a = 2;
    end
end
```

### Последовательная логика

Последовательная логика - это все, что связанно с триггерами.

```SystemVerilog
always_ff @(posedge clk) begin
    *** какая-то логика ***         <= объявление триггера
end
```

Важно обратить внимание на "posedge clk" в объявлении триггера - это значит, что триггер
"срабатывает" (поменяет значение), когда clk поменяет значение с 0 к 1. Если бы было написано
"negedge clk" - было бы наоборот.

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

always_ff @(posedge clk)            <= так лучше
    res2 <= b;

always_ff @(posedge clk)
    res3 <= c;
```

### Присваивания в комбинаторной и последовательной логике.

Как можно было заметить в последоваетльной (always_ff) и комбинаторной (always_comb или assign)
логиках, в примерах выше, использовались разные знаки присваивания:

```SystemVerilog
always_comb begin
    a = 10;                     <= обычный знак равно (=)
end

always_ff @(posedge clk) begin
    a <= 10;                    <= стрелочка (<=)
end
```

Если не вдоваться в подробности, просто используйте данные присваивания в соответствующих блоках
и не партесь.

Если хотите подробностей, получайте.

#### Блокирующие присваивания

Блокирующие присваивания (обычный знак "=") используются в комбинаторных блоках (always_comb, assign).
Блокирующими эти присваивания называются из-за механизма их работы:

```SystemVerilog
always_comb begin       Важными свойстом таких присваиваний является их последовательность при выполнении:
    a = 1;              <= Выполняется первым
    a = 2;              <= Выполняется вторым
    a = 3;                  ............
    a = 4;
    a = 5;              <= Выполняется пятым
end
```

Это даже немного очевидно, если смотреть на SystemVerilog со стороны языков обычного
программирования, но на самом деле мы имеем дело с описанем аппаратной, а не программной, части.
Такая последовательность позовляет привычным образом создавать нужную вам логику обработки данных.

#### Неблокирующие присваивания

Неблокирующие же присваивания ("<=") используются в триггерах, чья главная функция - сохранение
данных, а не их обработка. Отсюда, кстати, желательное разделение логики на последовательную и
комбинаторную.

```SystemVerilog
always_ff @(posedge clk) begin
    a <= 10;
    b <= 12;                     <= Здесь присваивание трех переменных происходит одновременно,
    c <= 5;                         когда clk меняет значение (от 0 к 1, если это posedge)
end
```

____

## P.S.

При возникновении вопросов/пожеланий/претензий (если вы каким-то образом дочитали до этого пункта)
можете передавать их через issue (или через старосту, что вернее).