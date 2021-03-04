#SystemVerilog Examples

Несколько тестовый примеров SystemVerilog кода для симулятора QuestaSim.

Требования для запуска:
1. Установленный и прописанный в PATH QuestaSim.
2. Умение запустить консоль и переместится в нужную папку.
3. Набрать команду "qustasim -do work.do"

Для удобного запуска создан work.do файл со всеми нужными командами.

____

##Примеры кода

Example 1: простой testbanch (tb) с синхросигналом (clk), сигналом сброса (reset_n) и элементарным
модулем add, реализующим синхронное сложение/вычитание. В tb добавлены два case - один для сложение,
один для вычитания.