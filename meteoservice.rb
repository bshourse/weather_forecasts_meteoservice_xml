require_relative 'lib/meteoservice_forecast'
require 'cgi/util'
require 'net/http'
require 'rexml/document'

CITIES = {
    37 => 'Москва',
    69 => 'Санкт-Петербург',
    99 => 'Новосибирск',
    59 => 'Пермь',
    115 => 'Орел',
    121 => 'Чита',
    141 => 'Братск',
    199 => 'Краснодар'
}.invert

def list_of_cities
  CITIES.keys.each_with_index do |name, index|
    puts "#{index+1}. #{name}"
  end
end

puts "Погоду для какого города вы хотите узнать?"

list_of_cities

user_input = STDIN.gets.to_i

# До тех пор пока юзер корректно не введет номер города мы будем отображать ему список с номерами городов
until user_input >= 1 && user_input <= CITIES.size
  puts "Введите номер города из списка:\n"
  puts "_"*80
  list_of_cities
  user_input = STDIN.gets.to_i
end

puts "="*80

# Как только юзер ввел корректный номер нам необходимо вытащить название города по данному индексу
user_city = CITIES.keys[user_input-1]

# А теперь когда мы вытащили название города, мы можем вытащить из хеша CITIES его порядковый номер
# и использовать его для конечного формирования url
user_city_id = CITIES[user_city]

URL = "https://www.meteoservice.ru/export/gismeteo/point/#{user_city_id}.xml".freeze

# URI.parse(URL) создает объект погода
# Отправляем запрос по адресу uri и сохраняем результат в переменную response
response = Net::HTTP.get_response(URI.parse(URL))

#парсим полученный xml
doc = REXML::Document.new(response.body)

#вытаскиваем из xml структуры город он у нас будет закодирован поэтому применим метод модуля CGI.unescape
town = CGI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

# Достаем все XML-теги <FORECAST> внутри тега <TOWN> и преобразуем их в массив

forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

puts town

forecast_nodes.each do |node|
  puts MeteoserviceForecast.from_xml_node(node)
  puts
end
