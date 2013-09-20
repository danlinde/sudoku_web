require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'
require_relative './lib/sudoku'
require_relative './helpers/application'

set :partial_template_engine, :erb
enable :sessions
set :session_secret, "I'm the secret key to sign the cookie"

use Rack::Flash


def random_sudoku
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    sudoku.solve!
    sudoku.to_s.chars
end

def puzzle(sudoku)
    sudoku.map {|v| rand < 0.3 ? 0 : v }
end

def generate_new_puzzle_if_necessary
  	return if session[:current_solution]
  	sudoku = random_sudoku
  	session[:solution] = sudoku
  	session[:puzzle] = puzzle(sudoku)
  	session[:current_solution] = session[:puzzle]    
end

def prepare_to_check_solution
  	@check_solution = session[:check_solution]
  	if @check_solution
  		flash[:notice] = "Incorrect values are highlighted in yellow"
  	end
  	session[:check_solution] = nil
end

get '/' do
	  prepare_to_check_solution
    generate_new_puzzle_if_necessary
  	@current_solution = session[:current_solution]
  	@solution = session[:solution]
  	@puzzle = session[:puzzle]
	  erb :index
end

post '/' do
  boxes = params["cell"].each_slice(9).to_a
  cells = (0..8).to_a.inject([]) {|memo, i|
    memo += boxes[i/3*3, 3].map{|box| box[i%3*3, 3] }.flatten
  }
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

post '/restart' do
  session[:current_solution] = session[:puzzle]
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  @solution = session[:solution]
  @puzzle = session[:solution]
  erb :index
end

get '/form' do
  erb :form
end

post '/form' do
  "You entered '#{params[:message]}'"
end

not_found do
  status 404
  "No page found"
end
