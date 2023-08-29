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
		content TEXT
	)'

	#создает таблицу если она не существует - if not exists 
	@db.execute 'CREATE TABLE if not exists Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id INTEGER
	)'

end

get '/' do
	# выводим список постов из БД

	@results = @db.execute 'select * from Posts order by id desc' 

	erb :index			
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

  # сохранение данных в БД

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  redirect to '/'
end

# вывод информации о посте
get '/details/:post_id' do

	# получаем переменную url
	post_id = params[:post_id]

	# получаем список постов 
	# у нас будет только один пост
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	# выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем комментарии для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса  /details/
# браузер отправляет данные на сервер, мы их принимаем

post '/details/:post_id' do

# получаем переменную url
	post_id = params[:post_id]

# получаем переменную из post-запроса	
  content = params[:content]

  # сохранение данных в БД

  @db.execute 'insert into Comments
  	(
  		content,
  		created_date,
  		post_id
  	) 
  		values
  	(
  		?,
  		datetime(),
  		?
  	)', [content, post_id]

  	# перенаправляем на страницу поста 
	redirect to ('/details/' + post_id)	  

end