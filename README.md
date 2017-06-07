# RuSlang-app

Проект: Слово за слово, приложение-словарь русского слэнга
Лотфуллин Камиль Равилевич
Студент 2 курса, 152 группа, ПМИ ФКН ВШЭ

Цель: Разработка и запуск ios-приложения "Словарь русского слэнга".

Языки разработки: Swift, Python, HTML, Javascript.

Средства разработки: Xcode, PyCharm, PhpStorm.

План реализации проекта:
  1. Выполнить Parse необходимых ресурсов(Сайт сленговых русских слов, Твиттер). Это можно делать всевозможными способами, я выбрал парсинг сайта с помощью Python и библиотек Selenium и BeautifulSoup. Язык Python и данные библиотеки выбраны из-за относительной простоты использования и популярности такого решения. Так как проект не рассчитан на продвинутый скоростной парсинг, то этих простых решений будет совершенно достаточно. Также планируется работа с Twitter API для анализа твитов на предмет наиболее употребляемых слэнговых слов. Далее создать базу данных на основе полученных результатов для удобного и практичного доступа к результатам.
  2. Подключить Google Firebase(или аналогичное облако) для кроссплатформенной передачи данных. Выбран FireBase из-за доступности и современности.
  3. Создать скелет приложения. Сформировать основной функционал и установить цели. Для этого предстоит пройти несколько видео-курсов освоения языка Swift, работа с официальной документацией. Программирование допустимо только в Xcode, так как это единственная платформа, предназначенная для создания iOS - приложений на языке Swift. Сам язык Swift выбран из-за его актуальности, относительной молодости и бурного развития и интереса мировой аудитории. Swift создан Apple специально на замену Objective-C, следовательно поэтому выбран первый, а не второй. 
  4. Рассмотреть и выделить различные features, которые потенциально планируется добавить в проект. В идеале хочется добавить как можно больше различных "фишек", для того чтобы познать суть многих актуальных дополнений. В финальной версии возможно они будут не нужны, но в процессе обучения, это необходимо для максимально близкого знакомства со Swift и iOS программированием.  
  5. Установка дополнений и совершенствование кода. Графическая оформление и улучшенная визуализация. Данный этап заключительный, здесь все пока совсем не ясно, будет редактироваться, дополняться. 
  6. В перспективе готовить приложение к запуску в открытый доступ в App Store.

Архитектура приложения:
  1. Ядро приложения, которое включает в себя компоненты системы, не доступные для взаимодействия с пользователем.
  2. Графический пользователь интерфейс
  3. Компоненты повторного использования: библиотеки, визуальные компоненты и другое.
  4. Файлы окружения: AppDelegate, .plist и т. д.
  5. Ресурсы приложения: графические файлы, звуки, необходимые бинарные файлы.

Инструкция по компиляции:
  1. Необходим компьютер на MacOS с установленным Xcode версии выше 8.0
  2. Скачать репозиторий.
  3. Открыть проект SlangApp.xcodeproj в папке SlangApp_
  4. Скомпилировать проект на симуляторе iOS или на подключенном iOS устройстве версии выше 10.0 при включенном соединении с интернет.

Реализованный функционал на данный момент:
  1. Главный экран WordsTableViewController, на котором присутствуют тестовые позиции слов, которые представлены с помощью кастомной ячейки WordsTableViewCell, показана ячейка поиска в списке слов.
  2. В WordsTableViewCell реализованы основные функции ячеек с базовыми характеристиками тестовых слов, показана возможность добавить в избранное, краткое описание слова. При нажатии на позицию открывается следующий вид
  3. Экран слов WordViewController с подробным описанием слова: названием, значением, историей происхождения(если имеется), добавление в избранное, часть речи(если имеется), пример использования(если имеется), возможность поделиться словом в основные источники.


