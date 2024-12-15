import random
import time

with open('screenmem.mem', 'w') as file:
    # Write 1200 lines of '0'
    for _ in range(1200):
        file.write('0\n')

def sum_of_hand(hand: list[int]) -> int:
    total: int = 0
    aces: int = 0
    for card in hand:
        card = card % 13
        if card == 0:
            card = 13
        if card > 10:
            total += 10
        elif card == 1:
            aces += 1
            total += 11
        else:
            total += card
    while total > 21 and aces:
        total -= 10
        aces -= 1
    return total

print("Welcome to the game of Blackjack!")
print("Select an amount to buy in.")
bank:float = float(input())
while bank > 0:
    blackjack:bool = False

    print("=====================================")
    print("You have $", bank)
    print("Player 1, set your wager or -1 to quit.")
    player_1_wager: float = float(input())
    if player_1_wager == -1:
        print("Goodbye!")
        break

    player_1_hand: list[int] = [random.randint(1, 52), random.randint(1, 52)]

    deck_dictionary: dict[int, str] = {
        1: "Ace of Spades", 2: "2 of Spades", 3: "3 of Spades", 4: "4 of Spades", 5: "5 of Spades", 6: "6 of Spades", 7: "7 of Spades", 8: "8 of Spades", 9: "9 of Spades", 10: "10 of Spades", 11: "Jack of Spades", 12: "Queen of Spades", 13: "King of Spades",
        14: "Ace of Hearts", 15: "2 of Hearts", 16: "3 of Hearts", 17: "4 of Hearts", 18: "5 of Hearts", 19: "6 of Hearts", 20: "7 of Hearts", 21: "8 of Hearts", 22: "9 of Hearts", 23: "10 of Hearts", 24: "Jack of Hearts", 25: "Queen of Hearts", 26: "King of Hearts",
        27: "Ace of Diamonds", 28: "2 of Diamonds", 29: "3 of Diamonds", 30: "4 of Diamonds", 31: "5 of Diamonds", 32: "6 of Diamonds", 33: "7 of Diamonds", 34: "8 of Diamonds", 35: "9 of Diamonds", 36: "10 of Diamonds", 37: "Jack of Diamonds", 38: "Queen of Diamonds", 39: "King of Diamonds",
        40: "Ace of Clubs", 41: "2 of Clubs", 42: "3 of Clubs", 43: "4 of Clubs", 44: "5 of Clubs", 45: "6 of Clubs", 46: "7 of Clubs", 47: "8 of Clubs", 48: "9 of Clubs", 49: "10 of Clubs", 50: "Jack of Clubs", 51: "Queen of Clubs", 52: "King of Clubs"
        }

    print(f"Player 1's hand: {deck_dictionary[player_1_hand[0]]}, {deck_dictionary[player_1_hand[1]]}")

    if sum_of_hand(player_1_hand) == 21:
        print("Blackjack!")
        blackjack = True
        bank += player_1_wager * 1.5
    if not blackjack:
        dealer_hand: list[int] = [random.randint(1, 52)]
        print(f"Dealer's hand: {deck_dictionary[dealer_hand[0]]}")

        hit:bool = True
        bust:bool = False
        
        while hit:
            print("Player 1, would you like to hit or stand?")
            hit_or_stand = input("Enter 'hit' or 'stand': ")
            if hit_or_stand == "hit":
                player_1_hand.append(random.randint(1, 52))
                print("Player 1's hand: ")
                for card in player_1_hand:
                    print(deck_dictionary[card])

                if sum_of_hand(player_1_hand) > 21:
                    print("Player 1 busts!")
                    bust = True
                    bank -= player_1_wager
                    break

            elif hit_or_stand == "stand":
                hit = False
            else:
                print("Invalid input. Please enter 'hit' or 'stand'.")
        dealer_bust:bool = False
        if not bust:
            print("=====================================")
            print("Dealer's hand: ")
            print(deck_dictionary[dealer_hand[0]])
            while sum_of_hand(dealer_hand) < 17:
                time.sleep(3)
                dealer_hand.append(random.randint(1, 52))
                print(deck_dictionary[dealer_hand[-1]])
                if sum_of_hand(dealer_hand) > 21:
                    print("Dealer busts!")
                    bank += player_1_wager
                    dealer_bust = True
                    break
            if not dealer_bust:
                if sum_of_hand(player_1_hand) > sum_of_hand(dealer_hand):
                    print("Player 1 wins!")
                    bank += player_1_wager
                elif sum_of_hand(player_1_hand) < sum_of_hand(dealer_hand):
                    print("Player 1 loses!")
                    bank -= player_1_wager