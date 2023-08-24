#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


 	
def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

# вызывается каждый раз при перезагрузке
# любой страницы
before do
	# инициализация БД
	init_db
end 

# configure вызывается каждый раз при конфигурации приложения,
# когда изменился кодпрограммы и перезагрузлась страница

configure do
	# инициализация БД
	init_db

	#создает таблицу если она не существует - if not exists 
	@db.execute 'CREATE TABLE if not exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		contend TEXT
	)'

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

# обработчик get-запроса /new
# браузер получает страницу с сервера

get '/new' do
  erb :new
end

# обработчик post-запроса /new
# браузер отправляет данные на сервер

post '/new' do

# получаем переменную из post-запроса	
  content = params[:content]
  
  if content.length <= 0
  	@error = 'Type TEXT'
  	return erb :new
  end 	 	 

  erb "You typed: #{content}"
end