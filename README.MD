# Нормализация данных о работе автосервиса

### Вводные
- исходный датасет в csv
- записи дублируются и имеют пропущенные значения

### Задачи
- заполнить пропуски
- уйти от дублей
- привести к 3НФ
- добавить автоинкрементные первичные ключи
- добавить связи между таблицами
- добавить индексы

### Использование
- создать базу в PostgreSQL (желательно 16.3 версии)
- создать и заполнить таблицу с исходными данными из csv
  - обязательно нужно удалить или заменить (на t) символ \ в файле csv, иначе будет ошибка при импорте
  - импорт лучше делать средствами DBeaver (проверено), что позволит избавиться от лишних пробелов и заполнить NULL-значениями пустые
  - "сырую" таблицу лучше назвать по первой части имени csv "d9140d6a", в противном случае нужно будет переименовать все обращения к указанному имени
- для заполнения пропущенных значений используется fill_blanks.sql
- для создания таблиц, ключей, индексов и ключевого представления (без дублей) - create_tables.sql
- для создания витрин с анализов данных в разных разрезах - show_data.sql

### Дополнительно
- есть дамп базы dump-test_car_service-202410232149.tar
  - можно восстановить через DBeaver (вызовет pg_restore)
  - можно через pg_restore
- есть проект ERD (car_service.svg) с планом нормализации