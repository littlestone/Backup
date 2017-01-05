# title - Baccarat.py

import random


_cards = [
("1", 1),
("2", 2),
("3", 3),
("4", 4),
("5", 5),
("6", 6),
("7", 7),
("8", 8),
("9", 9),
("10", 0),
("J", 0),
("Q", 0),
("K", 0),
("A", 1),
]


class Card(object):
    """A card object with name and value"""
    def __init__(self, name, value):
        self.name = name
        self.value = value


cards = [Card(n, v) for n, v in _cards]


class Shoe(list):
    """A collection of 8 decks of cards"""
    def __init__(self):
        self[:] = cards*(4*8)
        random.shuffle(self)
    def deal(self, two_players):
        for i in range(2):
            for j in two_players:
                j.hand.append(self.pop())
    def thirdCard(self, player):
        player.hand.append(self.pop())
    #...


class Player(object):
    """simple Player object that
       keeps tabs on bets and kitty"""
    def __init__(self, name):
        self.name = name
        self.kitty = 2000
        self.hand = []
        self.wager = 0
    def bet(self, wager):
        self.wager = wager
        self.kitty -= wager


class PlayerList(list):
    """It didn't seem right to update
        a list of players in the 
        Player class and I did it this
        way rather than using a list
        and two functions"""
    def win(self):
        for i in self:
            i.kitty += i.wager*2
    def draw(self):
        for i in self:
            i.kitty += i.wager     


def total(hand):
    #In baccarat the tens are discarded
    return sum([i.value for i in hand])%10


def bankersThird(last_card, bankers_cards):
    #Shows if the bank must stand or draw
    if last_card == 0:
        return bankers_cards < 4
    elif last_card == 9:
        if bankers_cards == 3:
            return random.choice(True, False)
        else:
            return bankers_cards < 3
    elif last_card == 8:
        return bankers_cards < 3
    elif last_card in (6, 7):
        return bankers_cards < 7
    elif last_card in (4, 5):
        return bankers_cards < 6
    elif last_card in (3, 2):
        return bankers_cards < 5
    elif last_card == 1:
        return bankers_cards < 4
    elif isinstance(last_card, str):
        return bankers_cards < 6


def playersThird(player, shoe):
    #A slapped wrist for the print statement, but I was using the all the same statements
    #when the total was < 5 or == 5, only the input was different.
    shoe.thirdCard(player)
    players_cards = total(player.hand)
    last_card = player.hand[-1].value
    print("You drew a {0}, making a total of {1}".format(last_card, players_cards))
    return players_cards, last_card


def initPlayers():
    players = PlayerList()
    while True:
        player = input("What is your name? 'f' to finish. ")
        if player == "f":
            break
        players.append(Player(player))
    return players


def legalBet(amount, available, kitty):
    #Can't bet over the bank limit, or over your own kitty.
    return amount.isdigit() and int(amount) <= available and int(amount) <= kitty


def takeOffBets(players):
    #Just trying to make main() a bit neater.
    for j in players:
        if j.wager == 1000:
            continue
        j.kitty += j.wager
        j.wager = 0
        
    
def placeBets(players):
    bank_amount = 1000
    total_bets = 0
    bet = ""
    for i in players:
        while not legalBet(bet, bank_amount-total_bets, i.kitty):
            bet = input("How much do you bet {1}? (Must be an integer. Maximum is {0}) ".format(min(bank_amount-total_bets, i.kitty), i.name))
            if bet == "banco":
                print("{0}'s going all the way!!".format(i.name))
                i.bet(1000)
                takeOffBets(players)
                for j in players:
                    print(j.name, j.wager, j.kitty)
                return           
        else:
            i.bet(int(bet))
            total_bets += int(bet)
            bet = "no"

            
def main():
    shoe = Shoe()        
    players = initPlayers()
    banker = Player("Banker")
    while 1:
        placeBets(players)    
        bets = [i.wager for i in players]
        the_player = players[bets.index(max(bets))]#Only the player with the maximum bet(nearest the banker's right) plays.
        two_players = [banker, the_player]
        shoe.deal(two_players)
        bankers_cards = total(banker.hand)
        players_cards = total(the_player.hand)
        print("The banker has a {0} and a {1}, making a total of {2}".format(banker.hand[0].name, banker.hand[1].name,bankers_cards))
        print("{0} has a {1} and a {2}, making a total of {3}".format( the_player.name, the_player.hand[0].name, the_player.hand[1].name, players_cards))
        if bankers_cards in (8, 9) or players_cards in (8, 9):
            if bankers_cards > players_cards:
                print("The bank wins with a natural {0}".format(bankers_cards))
            elif bankers_cards < players_cards:
                print("{0} wins with a natural {1}".format(the_player.name, players_cards))
                players.win()
            elif bankers_cards == players_cards:
                print("There is a draw.")
                players.draw()
            else:
                print("Not won, lost or drawn!")
            for i in players:
                print(i.name+" has "+str(i.kitty))
            for i in two_players:
                i.hand = []
            continue
        if players_cards > 5:
            print("You must stand on a {0}".format(players_cards))
            last_card = "no card"
        elif players_cards < 5:
            print("You must draw to a {0}".format(players_cards))
            players_cards, last_card = playersThird(the_player, shoe)            
        else:
            standordraw = "no"
            while not standordraw in ("d", "s"):
                standordraw = input("You have 5. Do you want to (s)tand or (d)raw? ")
            if standordraw == "d":
                players_cards, last_card = playersThird(the_player, shoe)    
        if bankersThird(last_card, bankers_cards):        
            shoe.thirdCard(banker)
            bankers_cards = total(banker.hand)
            print("The bank draws a {0}".format(banker.hand[-1].name))
        if bankers_cards > players_cards:
            winner = "the banker"
        elif bankers_cards < players_cards:
            winner =  the_player.name
            players.win()            
        elif bankers_cards == players_cards:
            winner = "nobody, because it's a draw."
            players.draw()                
        print("The banker scores {0} and {1} scores {2}. The winner is {3}".format(bankers_cards, the_player.name, players_cards, winner))
        for i in players:
                print(i.name+" has "+str(i.kitty))
        for i in two_players:
            i.hand = []        


main() 
