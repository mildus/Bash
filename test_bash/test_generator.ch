# /bin/bash


########################### Генератор простых тестов pageload  #################################

# Путь к папке test_suites
PATH_TESTSUITES="/home/u/test/tests_undeground/test_suites"

### Получение данных через диалог
PAGE_NAME=$(zenity --title "Ввод данных" --entry --text "Введите название страницы")
PATH_FOR_SAVE=$(zenity --title "Ввод данных" --entry --text "Введите путь до папок test и helper"  --entry-text="/core/catalogs/")
XPATH=$(zenity --title "Ввод данных" --entry --text "Введите xpath"  --entry-text="//")
TESTIT_ID=$(zenity --title "Ввод данных" --entry --text "Введите ID из TestIT")

### Переменные для подстановки в файлы

# Основная папка - core, dig, underground...
MAIN_FOLDER=$(echo $PATH_FOR_SAVE | cut -d'/' -f 2)

# Вложенная папка
SUB_FOLDER=$(echo $PATH_FOR_SAVE | cut -d'/' -f 3)

# Хелпер
HELPER="${PAGE_NAME}_helper"

TEST_FILE="test_${PAGE_NAME}.py"
TEST_PATH="${PATH_TESTSUITES}${PATH_FOR_SAVE}tests/"

HELPER_FILE="${PAGE_NAME}_helper.py"
HELPER_PATH="${PATH_TESTSUITES}${PATH_FOR_SAVE}helpers/"

# PascalCase для названия класса
CLASS=$(echo $PAGE_NAME | sed -r 's/(^|_)([a-z])/\U\2/g')

### Создание файла test_*.py
echo "# -*- coding: utf-8 -*-

import pytest
import allure
from test_suites.$MAIN_FOLDER.$SUB_FOLDER.helpers.$HELPER import $CLASS


@allure.label('testcase', '$TESTIT_ID')
@pytest.mark.komsomol
def test_core_enterprise(app):

    \"\"\" Загрузка страницы и проверка данных \"\"\"
    page = $CLASS(app)
    page.open_page(page.frame_src)
    page.controls_set(app)
    page.check_data_shown()

    \"\"\" Закрытие фрейма \"\"\"
    page.close_active_frame()
">${TEST_PATH}/${TEST_FILE}



### Создание файла *_helper.py
echo "# -*- coding: utf-8 -*-

import allure
from page_object.catalog_page import CatalogPage
from page_object.left_bar import refresh
from page_object.base_test import avoid_blocking_panel


class $CLASS(CatalogPage):

    frame_src = \"$PAGE_NAME\"

    @allure.step(\"Установка контролов\")
    def controls_set(self, app):
        avoid_blocking_panel(app.wd)
        refresh(app.wd)

    @allure.step(\"Проверка загрузки данных\")
    def check_data_shown(self):

        self.switch_to_frame_and_load(self.frame_src)
        self.re_switch(self.frame_src)

        data_strings = \"$XPATH\"

        # Запрашиваем элементы
 
        self.check_elements_loaded(data_strings)

">${HELPER_PATH}${HELPER_FILE}
