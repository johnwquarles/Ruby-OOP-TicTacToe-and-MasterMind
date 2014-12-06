module MMind
  def MMind.genAnswerRandom
    (0..3).map {|i| rand(1..6)}
  end
  
  def MMind.genHash(array)
    hash = {}
    array.each do |i|
      if hash.keys.include?(i)
        hash[i] += 1
      else
        hash[i] = 1
      end
    end
    hash
  end
  
  def MMind.getInputHum(type)
    puts "", "Please enter your #{type} as four digits, each digit between one and six,",
         "without spaces, eg \"6342\".", ""
    guess = gets.chomp.to_s.split("").map {|i| i.to_i}
    unless ( (guess.all? {|i| i.between?(1,6)} ) && guess.length == 4)
      puts "", "Your #{type} was not understood. Please reenter.", ""
      return getInputHum(type)
    end
    guess
  end

  def MMind.responseToGuess(guess, answer)
    response = ""
    finished_indices = []
    guess.each_with_index do |i, index| 
      if i == answer[index]
        response << "O"
        finished_indices << index
      end
    end
    
    remaining_answer = []
    remaining_guess = []
    guess.each_with_index do |i, index|
      if not finished_indices.include?(index)
        remaining_answer << answer[index]
        remaining_guess << i
      end
    end
    
    remaining_answer_hash = genHash(remaining_answer)
    remaining_guess_hash = genHash(remaining_guess)
    remaining_guess_hash.each do |key, value|
      answer_value = remaining_answer_hash.fetch(key, 0)
      [answer_value, value].min.times {response << "X"}
    end
    
    (4 - response.length).times {response << "_"}
     
    response
  end

  def MMind.checkAnswer(guess, answer)
    return true if guess == answer
  end

  def MMind.getRaw(array)
    raw = ""
    array.each {|i| raw << i.to_s}
    raw
  end

  def MMind.getCompGuess(prev_guess = nil, prev_response = nil)
    return genAnswerRandom if (prev_guess == nil && prev_response == nil)
    prev_Os = prev_response.count("O")
    prev_Xs = prev_response.count("X")
    guess = [nil, nil, nil, nil]
    
    # for each "O" that the previous response had, choose a random digit to keep in position
    @O_indices = (0..3).to_a.shuffle.take(prev_Os)
    @O_indices.each {|i| guess[i] = prev_guess[i]}
    @indices_left = (0..3).to_a - @O_indices
    
    # for each "X" that the previous response had, place a random digit into a random position
    @indices_left_shuff = @indices_left.shuffle
    @X_indices = @indices_left.shuffle.take(prev_Xs)
    @X_indices.each_with_index {|i, index| guess[i] = prev_guess[@indices_left_shuff[index]]}
    
    #fill in any remaining gaps with random numbers
    final = guess.map do |i| 
      if i == nil
        rand(1..6)
      else
        i
      end
    end  
    final
  end
end

class HumanGame
  def initialize
    @turn = 1
    @answer = MMind.genAnswerRandom
  end

  attr_accessor :turn
  attr_reader :answer

  def gameStart
    puts "", "The computer has chosen a random 4-digit code consisting of digits between 1 and 6."
    puts "As you make guesses, you'll receive a four-character response."
    puts "O means that you have a digit correctly placed."
    puts "X means that a number that you guessed is in the code, but was not guessed in its correct position."
    puts "_ means that one of your guess digits is not contained within the answer code."
    puts "Note that the order of these feedback characters is irrelevant!"
    puts "ie, an \"O\" in the first position does not necessarily mean that the first digit was correctly placed."
    puts "The response is simply set up to always display Os, then Xs, and last _s."
    puts "", "You have 12 turns to guess the code!", ""    
    running_feedback = "\n"
    while turn <= 12
      puts "", "Turn number : #{turn}"
      if turn == 12
        puts "\n     Last chance! \n"
      end
      guess = MMind.getInputHum("guess")
      response = MMind.responseToGuess(guess, @answer)
      running_feedback += "Turn #{@turn}: #{MMind.getRaw(guess)} -> #{response} \n"
      print running_feedback
      if MMind.checkAnswer(guess, @answer)
        win = true
        @turn = 13
      end
      @turn += 1
    end
    unless win
      puts "","Your 12 turns are up! Game over!", ""
      puts "The answer was: #{MMind.getRaw(answer)}", ""
      return
    end
    puts "", "You win! No code is safe!", ""
  end
end

class ComputerGame < HumanGame
  def initialize
    super
    @answer = MMind.getInputHum("code")
    @two_answer = []
    @three_answer = []
    @two_found = false
    @three_found = false
  end
  
  def gameStart
    puts "", "The computer has 12 chances to break your code.", ""
    running_feedback = "\n"
    prev = nil
    prev_response = nil
    turn_copy = 0
    while turn <= 12 
      puts "", "Turn number: #{turn}", "", "Press return to continue"
      gets
      # if a previous computer guess response had 3 Os, keep basing new guesses from the
      # first such guess that got those 3 Os.
      # likewise for guesses that had 2 Os (but 3 O guesses take precedence).
      if @three_found
        to_guess = @three_answer
      elsif @two_found
        to_guess = @two_answer
      else
        to_guess = prev
      end
      
      guess = MMind.getCompGuess(to_guess, prev_response)
      response = MMind.responseToGuess(guess, @answer)
      
      case response.count("O")
      when 3
        @three_found = true
        @three_answer = guess if @three_answer == []
      when 2
        @two_found = true
        @two_answer = guess if @two_answer == []
      end
      
      running_feedback += "Turn #{@turn}: #{MMind.getRaw(guess)} -> #{response} \n"
      print running_feedback
      if MMind.checkAnswer(guess, @answer)
        win = true
        turn_copy = @turn
        @turn = 13
      end
      @turn += 1
      prev = guess
      prev_response = response
    end
    unless win
      puts "", "The computer was no match for your intimidating intellect!", ""
      return
    end
    puts "", "The computer guessed your answer in #{turn_copy} turns!", ""
  end
end

def game
  puts "","Welcome to Generic Command-Line MasterMind!", ""
  puts "Would you like to:", "", "1. Break the code?", "2. Make the code?", ""
  input = gets.chomp.to_s
  input_miss = false
  case input
  when "1"
    game = HumanGame.new
    game.gameStart
  when "2"
    game = ComputerGame.new
    game.gameStart
  else
    puts "", "Your input was not understood!"
    input_miss = true
  end
  if input_miss
    game()
  else
    newGameQuestion
  end
end 
  
def newGameQuestion
  puts "New game? Y/N", ""
  response = gets.chomp.to_s.upcase[0]
  case response
  when "Y"
    game()
  when "N"
    puts "Thanks for playing!"
    return
  else
    puts "", "Run that by me again please!", ""
    again = true
  end
  newGameQuestion if again == true
end  

game()
  
  
    
    