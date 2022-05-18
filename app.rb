#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'lepra.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS  "Posts" (
	"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date" DATE,
	"content"	TEXT
)'

	@db.execute 'CREATE TABLE IF NOT EXISTS  "Comments" (
	"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date" DATE,
	"content"	TEXT,
	"post_id" INTEGER
)'


end

get '/' do

	#выбираем список постов из бд и пишем порядок постов

	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]
	if content.length <= 0
		@error = "No post typed!"
 	return erb :new
	end
#сохранение данных в БД
@db.execute 'insert into Posts (created_date, content) values (datetime(), ?)', [content]


#перенаправление
redirect to '/'
 	erb content
end

get '/details/:post_id' do
	#получаем переменную из url

	post_id = params[:post_id]
	#получаем список постов ( у нас только один)
	@results = @db.execute 'select * from Posts where id = ?', [post_id]
	#выбираем этот один пост в переменную @row
	@row = @results[0]
	#возвращаем details.erb

	erb :details
end
#обработчик пост-запроса (браузер отправляет данные.а мы их принимаем)

post '/details/:post_id' do
post_id = params[:post_id]
content = params[:content]

 @db.execute 'insert into Comments (created_date, content, post_id) values (datetime(), ?, ?)', [content, post_id]


redirect to('/details/' + post_id)


end






get '/main' do
	erb "Hello world"
end

