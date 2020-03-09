require 'open-uri'

class GamesController < ApplicationController
  def new
    @score ||= session[:score]
    @score = 0 if @score.nil?
    @letters = []
    (0...10).map { @letters << ('A'..'Z').to_a[rand(26)] }
  end

  def score
    @score = params[:score].to_i
    url = "https://wagon-dictionary.herokuapp.com/#{params[:word]}"
    word_serialized = open(url).read
    word_response = JSON.parse(word_serialized)
    letters = params[:letters].split
    word = params[:word].split('')

    grid = reduce(letters)
    attempt = reduce(word)

    check = attempt.all? do |k, _v|
      if grid[k]
        attempt[k] <= grid[k]
      else
        false
      end
    end

    if check && word_response['found']
      @score += word_response['length']
      @message = "Congratulations! #{params[:word]} is a valid English word!"
    elsif check
      @score += 0
      @message = "Sorry but #{params[:word]} does not seem to be a valid English word..."
    else
      @score += 0
      @message = "Sorry but #{params[:word]} can't be built out of #{letters}"
    end
    session[:score] = @score
  end

  private

  def reduce(words)
    words.reduce({}) do |accu, alphabet|
      accu[alphabet] = accu[alphabet] ? accu[alphabet] + 1 : 1
      accu
    end
  end
end
