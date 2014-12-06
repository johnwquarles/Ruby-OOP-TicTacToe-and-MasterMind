class Cell
  def initialize
    @value = nil
  end
  
  def value
    return " " if @value == nil
    @value
  end
  
  def set(player)
    unless value == " "
      puts "", "That square is already taken!", ""
      return false
    end
    @value = player.symbol
  end
end

class Player
  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end
  
  attr_reader :symbol
  attr_reader :name
end

class Game
  def initialize
    @players = playerSet
    @game_over = false
  end
  
  attr_reader :players
  attr_reader :cells
  attr_accessor :game_over
  
  def print
    div = "---+---+---"
    puts " #{cells[1].value} | #{cells[2].value} | #{cells[3].value} "
    puts div
    puts " #{cells[4].value} | #{cells[5].value} | #{cells[6].value} "
    puts div
    puts " #{cells[7].value} | #{cells[8].value} | #{cells[9].value} "
  end

  def layout
    puts "|123|", "|456|", "|789|"
  end
  
  def playerTurnPrint(player)
    puts "", "Here's the board as it stands now:", ""
    print
    puts "", "And here's the layout for you to make your next move:", ""
    layout
    puts "", "It's #{player.name}'s turn!", ""
  end
  
  def playerTurnSelect(player)
    puts "Please enter a single digit to specify your move.", ""
    player_choice = gets.chomp.to_i
    if not player_choice.between?(1,9)
      puts "", "Your input was not understood!", ""
      again = true
    else
      again = true if not cells[player_choice].set(player)
    end
    playerTurnSelect(player) if again
    detectTie if detectWin(player) == false
  end
    
  def detectWin(player)
    winners = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[3,5,7],[1,5,9]]
    winners.each do |a,b,c|
      if ( cells[a].value == player.symbol && cells[b].value == player.symbol && cells[c].value == player.symbol )
        return endGameWin(player)
      end
    end
  return false
  end
  
  def detectTie
    contents = (1..9).map {|i| cells[i].value}
    endGameTie() if contents.none? { |i| i == " " }
  end
  
  def endGameWin(player)
    puts
    print
    puts "", "The winner is #{player.name}!", "", "#{player.name} is truly a Tic-Tac-Terror!", ""
    self.game_over = true
  end
  
  def endGameTie
    puts
    print
    puts "", "Cat's game!", ""
    self.game_over = true
  end
  
  def playerSet
    player_array = []
    puts "What shall we name player one?"
    p1name = gets.chomp.to_s
    puts "And what one-character symbol will #{p1name} use?"
    p1sym = gets.chomp.to_s[0]
    player_array << Player.new(p1name, p1sym)
    
    puts "How about player two's name?"
    p2name = gets.chomp.to_s
    puts "And #{p2name}'s one-character symbol will be?"
    p2sym = gets.chomp.to_s[0]
    player_array << Player.new(p2name, p2sym)
    return player_array
  end
  
  def newGameQuestion(players)
    puts "New game? Y/N", ""
    response = gets.chomp.to_s.upcase[0]
    case response
    when "Y"
      startGame
    when "N"
      puts "Thanks for playing!"
      return
    else
      puts "", "Run that by me again please!", ""
      again = true
    end
    newGameQuestion(players) if again == true
  end
  
  def startGame
    i = 0
    self.game_over = false
    @cells = {}
    (1..9).each {|i| @cells[i] = Cell.new}
    while self.game_over == false
      playerTurnPrint(players[i % 2])
      playerTurnSelect(players[i % 2])
      i += 1
    end
    newGameQuestion(players)
  end  
end

game = Game.new
game.startGame()