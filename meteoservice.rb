require_relative 'lib/meteoservice_forecast'
require 'cgi/util'
require 'net/http'
require 'rexml/document'

URL = 'https://www.meteoservice.ru/export/gismeteo/point/37.xml'.freeze

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
