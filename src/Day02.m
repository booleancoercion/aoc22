#import "Day02.h"

typedef enum move {
    ROCK = 1,
    PAPER = 2,
    SCISSORS = 3
} move_t;

static move_t moveFromChar(char c) {
    switch(c) {
    case 'A':
    case 'X':
        return ROCK;

    case 'B':
    case 'Y':
        return PAPER;

    case 'C':
    case 'Z':
        return SCISSORS;

    default:
        @throw @"moveFromChar called with invalid value";
    }
}

typedef enum outcome {
    LOSS = 0,
    DRAW = 3,
    WIN = 6,
} outcome_t;

static outcome_t outcomeFromChar(char c) {
    switch(c) {
    case 'X':
        return LOSS;
    case 'Y':
        return DRAW;
    case 'Z':
        return WIN;
    default:
        return -1;
    }
}

@interface Game : OFObject
@property(nonatomic, readonly) move_t opponentMove;
@property(nonatomic, readonly) move_t playerMove;
@property(nonatomic, readonly) outcome_t outcome;
@property(nonatomic, readonly) int score;

+ (instancetype)gameWithMoves:(move_t)opponentMove playerMove:(move_t)playerMove;
+ (instancetype)gameWithMovesString:(OFString *)line;
+ (instancetype)gameWithMoveAndOutcome:(move_t)opponentMove outcome:(outcome_t)outcome;
+ (instancetype)gameWithMoveAndOutcomeString:(OFString *)line;
- (instancetype)initWithMoves:(move_t)opponentMove playerMove:(move_t)playerMove;
- (instancetype)initWithMovesString:(OFString *)line;
- (instancetype)initWithMoveAndOutcome:(move_t)opponentMove outcome:(outcome_t)outcome;
- (instancetype)initWithMoveAndOutcomeString:(OFString *)line;
- (outcome_t)outcome;
- (int)score;

- (instancetype)init OF_UNAVAILABLE;
@end

@implementation Game {
    BOOL _playerMoveMissing;
    move_t _playerMove;
    BOOL _outcomeMissing;
    outcome_t _outcome;
}

+ (instancetype)gameWithMoves:(move_t)opponentMove playerMove:(move_t)playerMove {
    return [[self alloc] initWithMoves:opponentMove playerMove:playerMove];
}

+ (instancetype)gameWithMovesString:(OFString *)line {
    return [[self alloc] initWithMovesString:line];
}

+ (instancetype)gameWithMoveAndOutcome:(move_t)opponentMove outcome:(outcome_t)outcome {
    return [[self alloc] initWithMoveAndOutcome:opponentMove outcome:outcome];
}

+ (instancetype)gameWithMoveAndOutcomeString:(OFString *)line {
    return [[self alloc] initWithMoveAndOutcomeString:line];
}

- (instancetype)initWithMoves:(move_t)opponentMove playerMove:(move_t)playerMove {
    self = [super init];

    _outcomeMissing = YES;
    _playerMoveMissing = NO;
    _opponentMove = opponentMove;
    _playerMove = playerMove;

    return self;
}

- (instancetype)initWithMovesString:(OFString *)line {
    OFArray<OFString *> *moves = [line componentsSeparatedByString:@" "];
    move_t opponentMove = moveFromChar([moves[0] characterAtIndex:0]);
    move_t playerMove = moveFromChar([moves[1] characterAtIndex:0]);

    return [self initWithMoves:opponentMove playerMove:playerMove];
}

- (instancetype)initWithMoveAndOutcome:(move_t)opponentMove outcome:(outcome_t)outcome {
    self = [super init];

    _outcomeMissing = NO;
    _playerMoveMissing = YES;
    _opponentMove = opponentMove;
    _outcome = outcome;

    return self;
}

- (instancetype)initWithMoveAndOutcomeString:(OFString *)line {
    OFArray<OFString *> *moves = [line componentsSeparatedByString:@" "];
    move_t opponentMove = moveFromChar([moves[0] characterAtIndex:0]);
    outcome_t outcome = outcomeFromChar([moves[1] characterAtIndex:0]);

    return [self initWithMoveAndOutcome:opponentMove outcome:outcome];
}

- (move_t)playerMove {
    if(_playerMoveMissing) {
        if(self.outcome == DRAW) {
            _playerMove = self.opponentMove;
        } else if(self.outcome == WIN) {
            _playerMove = self.opponentMove % 3 + 1;
        } else {
            _playerMove = (self.opponentMove + 1) % 3 + 1;
        }
        _playerMoveMissing = NO;
    }

    return _playerMove;
}

- (outcome_t)outcome {
    if(_outcomeMissing) {
        if(self.opponentMove == self.playerMove) {
            _outcome = DRAW;
        } else if(self.opponentMove == ROCK && self.playerMove == SCISSORS) {
            _outcome = LOSS;
        } else if(self.opponentMove == PAPER && self.playerMove == ROCK) {
            _outcome = LOSS;
        } else if(self.opponentMove == SCISSORS && self.playerMove == PAPER) {
            _outcome = LOSS;
        } else {
            _outcome = WIN;
        }
        _outcomeMissing = NO;
    }
    return _outcome;
}

- (int)score {
    return self.outcome + self.playerMove;
}
@end

static int calculateScore(OFArray<Game *> *games) {
    int sum = 0;
    for(Game *game in games) {
        sum += game.score;
    }

    return sum;
}

@implementation Day02 {
    OFArray<Game *> *_games1;
    OFArray<Game *> *_games2;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray<Game *> *games1 = [OFMutableArray array];
    OFMutableArray<Game *> *games2 = [OFMutableArray array];

    OFString *line;
    while((line = [stream readLine])) {
        line = [line stringByDeletingEnclosingWhitespaces];
        [games1 addObject:[Game gameWithMovesString:line]];
        [games2 addObject:[Game gameWithMoveAndOutcomeString:line]];
    }

    _games1 = games1;
    _games2 = games2;

    return self;
}

- (OFValue *)runPart1 {
    return @(calculateScore(_games1));
}

- (OFValue *)runPart2 {
    return @(calculateScore(_games2));
}
@end
