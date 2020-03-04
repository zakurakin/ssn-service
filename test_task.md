Написати web сервіс, що буде мати лише один відкритий роут POST /ssn.
request і response content-type має бути application/json.
Сервіс прийматиме наступну структуру:
```json
    {
        "id": 1,
        "name": "John",
        "state": "TN"
    }
```
Сервіс має провалідувати отримані дані за наступними правилами:
Всі поля обов'язкові. У випадку відсутності одного чи декількох полів, сервіс має повернути помилку у вигляді json зі статус кодом 422:
```json
    {
        "error": [
            "name": "is required",
            "state": "is required"
        ]
    }
```
id - ціле число, більше за 0
name - рядок з довжиною більше за 3,
state - один зі штатів в США (MA, DE, NY, etc)
У випадку не проходження валідації сервіс має повернути помилку зі статус кодом 422 і json наступного вигляду:
```json
    {
        "error": [
            "id": "should be an integer, greater than 0",
            "name": "can't be less than 3",
            "state": "invalid state"
        ]
    }
```
Отримані дані мають бути збережені сервісом в пам'ять (ets).
При збереженні в пам'ять потрібно перевірити що об'єкту з таким id не існує в пам'яті (якщо існує повернути помилку зі status code: 422 та текстом "Id should be unique") та сгенерувати 2 нових поля:
1. унікальний інкрементний request_id (ціле число, більше 0). 
2. security_number, що виглядає як 000-00-0000 і генериться за наступним алгоритмом:
перші три цифри - залежить від штату
003 NH    400 KY    530 NV 
004 ME    408 TN    531 WA
008 VT    416 AL    540 OR
010 MA    425 MS    545 CA
035 RI    429 AR    574 AK
040 CT    433 LA    575 HI
050 NY    440 OK    577 DC
135 NJ    449 TX    580 VI (Virgin Islands)
159 PA    468 MN    581 PR (Puerto Rico)
212 MD    478 IA    585 NM
221 DE    486 MO    586 PI (Pacific Islands)
223 VA    501 ND    587 MS
232 WV    503 SD    589 FL
237 NC    505 NE    596 PR (Puerto Rico)
247 SC    509 KS    600 AZ
252 GA    516 MT    602 CA
261 FL    518 ID    627 TX
268 OH    520 WY    646 UT
303 IN    521 CO    648 NM
318 IL    525 NM    
362 MI    526 AZ    
387 WI    528 UT
наступні дві - поточний номер тижня
останні чотири - request_id
Приклад збережених даних в пам'яті:
```
    [
        %{
            "id" => 1,
            "name" => "John",
            "security_number" => "003-08-0001",
            "request_id" => 1
        },
        %{
            "id" => 10,
            "name" => "Paul",
            "security_number" => "501-09-0002",
            "request_id" => 2
        } 
    ]
```
У випадку успішного респонсу, сервіс має повернути status code: 200 і security_number, request_id поля, напр.:
```json
    {
        "security_number": "501-09-0002",
        "request_id": 2
    }
```