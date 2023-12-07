from math import max, min


fn day7(args: VariadicList[StringRef]) raises:
    let input_lines = Path(args[1]).read_text().split("\n")

    print("Part1:", part1(input_lines))
    print("Part2:", part2(input_lines))


alias cards = "23456789TJQKA"
alias cardsWithJoker = "J23456789TQKA"
alias HandEnum = Int
alias HighCard: HandEnum = 0
alias OnePair: HandEnum = 1
alias TwoPairs: HandEnum = 2
alias ThreeOfAKind: HandEnum = 3
alias FullHouse: HandEnum = 4
alias FourOfAKind: HandEnum = 5
alias FiveOfAKind: HandEnum = 6


@value
struct Hand(CollectionElement, Stringable):
    var cards: String
    var hand_type: HandEnum
    var rank: Int
    var bet: Int
    var with_joker: Bool

    @staticmethod
    fn from_input_line(line: String, with_joker: Bool = False) raises -> Self:
        let split_line = line.split(" ")
        let cards = split_line[0]
        let bet = atol(split_line[1])

        var first_card_count: Int = cards.count(cards[0])
        var second_card_count: Int = cards.count(cards[1])
        var third_card_count: Int = cards.count(cards[2])
        var fourth_card_count: Int = cards.count(cards[3])
        var fifth_card_count: Int = cards.count(cards[4])
        if with_joker:
            if cards[0] == "J":
                first_card_count = 1
            if cards[1] == "J":
                second_card_count = 1
            if cards[2] == "J":
                third_card_count = 1
            if cards[3] == "J":
                fourth_card_count = 1
            if cards[4] == "J":
                fifth_card_count = 1
        let jokers = cards.count("J")

        let maximum = max(
            max(
                max(max(first_card_count, second_card_count), third_card_count),
                fourth_card_count,
            ),
            fifth_card_count,
        )
        let minimum = min(
            min(
                min(min(first_card_count, second_card_count), third_card_count),
                fourth_card_count,
            ),
            fifth_card_count,
        )
        let cards_sum = first_card_count + second_card_count + third_card_count + fourth_card_count + fifth_card_count

        let hand_type: HandEnum
        if maximum == 5:
            hand_type = FiveOfAKind
        elif maximum == 4:
            if with_joker and jokers:
                hand_type = FiveOfAKind
            else:
                hand_type = FourOfAKind
        elif maximum == 3:
            if minimum == 2:
                hand_type = FullHouse
            elif with_joker and jokers:
                hand_type = FullHouse + jokers
            else:
                hand_type = ThreeOfAKind
        elif maximum == 2 and cards_sum == 9:
            if with_joker and jokers:
                hand_type = FullHouse
            else:
                hand_type = TwoPairs
        elif maximum == 2:
            if with_joker and jokers:
                if jokers == 1:
                    hand_type = ThreeOfAKind
                elif jokers == 2:
                    hand_type = FourOfAKind
                else:
                    hand_type = FiveOfAKind
            else:
                hand_type = OnePair
        else:
            if with_joker and jokers:
                if jokers == 1:
                    hand_type = OnePair
                elif jokers == 2:
                    hand_type = ThreeOfAKind
                elif jokers == 3:
                    hand_type = FourOfAKind
                else:
                    hand_type = FiveOfAKind
            else:
                hand_type = HighCard

        return Self(
            cards=cards, hand_type=hand_type, rank=-1, bet=bet, with_joker=with_joker
        )

    fn update_rank(inout self, others: DynamicVector[Self]):
        var rank = 1

        if not len(others):
            return

        for i in range(len(others)):
            let other = others[i]
            if other < self:
                rank += 1

        self.rank = rank

    fn __eq__(self, other: Self) -> Bool:
        return self.cards == other.cards

    fn __lt__(self, other: Self) -> Bool:
        if self == other:
            return False
        if self.hand_type < other.hand_type:
            return True
        if self.hand_type > other.hand_type:
            return False
        for i in range(len(self.cards)):
            let card_rank: Int
            let other_rank: Int
            if self.with_joker:
                card_rank = String(cardsWithJoker).find(self.cards[i])
                other_rank = String(cardsWithJoker).find(other.cards[i])
            else:
                card_rank = String(cards).find(self.cards[i])
                other_rank = String(cards).find(other.cards[i])
            if card_rank == other_rank:
                continue
            return card_rank < other_rank

        return False

    fn __gt__(self, other: Self) -> Bool:
        return not self < other and not self == other

    fn __str__(self) -> String:
        return (
            "Hand (Cards="
            + self.cards
            + ", HandType="
            + self.hand_type
            + ", Rank="
            + self.rank
            + ", Bet="
            + self.bet
            + ")"
        )


fn part1(input_lines: DynamicVector[String]) raises -> Int:
    var hands = DynamicVector[Hand](capacity=len(input_lines))

    for i in range(len(input_lines)):
        let hand = Hand.from_input_line(input_lines[i])
        hands.push_back(hand ^)

    var total = 0
    for i in range(len(hands)):
        var rest = DynamicVector[Hand](capacity=len(hands) - 1)
        for j in range(0, len(hands)):
            if i != j:
                rest.push_back(hands[j])
        hands[i].update_rank(rest)
        total += hands[i].rank * hands[i].bet

    return total


fn part2(input_lines: DynamicVector[String]) raises -> Int:
    var hands = DynamicVector[Hand](capacity=len(input_lines))

    for i in range(len(input_lines)):
        let hand = Hand.from_input_line(input_lines[i], with_joker=True)
        hands.push_back(hand ^)

    var total = 0
    for i in range(len(hands)):
        var rest = DynamicVector[Hand](capacity=len(hands) - 1)
        for j in range(0, len(hands)):
            if i != j:
                rest.push_back(hands[j])
        hands[i].update_rank(rest)
        total += hands[i].rank * hands[i].bet

    return total
