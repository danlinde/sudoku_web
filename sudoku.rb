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
	# this method removes some of the digits
	# from the puzzle and is for me to implement
	sudoku
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
  	@current_solution = session[:current_solution] || session[:puzzle]
  	@solution = session[:solution]
  	@puzzle = session[:puzzle]
	erb :index
end

post '/' do
  cells = params["cell"]
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  erb :index
end