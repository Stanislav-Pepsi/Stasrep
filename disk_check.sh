#!/bin/bash

# Лимит свободного места (в процентах), при котором будет предупреждение
WARNING_LIMIT=10

# Получаем информацию о дисках
df -h | awk -v limit="$WARNING_LIMIT" '
NR==1 {
    print "\033[34m" $0 "\033[0m"  # Синий цвет для заголовка
}
NR>1 {
    # Удаляем знак процента и получаем число
    used_percent = $5
    gsub(/%/, "", used_percent)
    
    if (used_percent > (100 - limit)) {
        # Красный цвет для критического заполнения
        print "\033[31m" $0 "\033[0m"
    } else if (used_percent > 80) {
        # Желтый цвет для предупреждения
        print "\033[33m" $0 "\033[0m"
    } else {
        # Зеленый цвет для нормального состояния
        print "\033[32m" $0 "\033[0m"
    }
}'

# Дополнительная проверка с уведомлением
CRITICAL_DISKS=$(df -h | awk -v limit="$WARNING_LIMIT" 'NR>1 && $5+0 > (100 - limit) {print $6 " (" $5 ")"}')

if [ ! -z "$CRITICAL_DISKS" ]; then
    echo -e "\n\033[31mВНИМАНИЕ! Критически мало свободного места на:\033[0m"
    echo "$CRITICAL_DISKS" | while read -r line; do
        echo -e "• $line"
    done
    # Можно добавить отправку email или другого уведомления
    # echo "Alert!" | mail -s "Low disk space" admin@example.com
fi