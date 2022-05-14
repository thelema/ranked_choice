import 'package:ranked_choice/ranked_choice.dart';
import "package:test/test.dart";

main() {
  test('RCO singleton', () {
    expect(
        rankedChoiceOrder<int>([
          [3],
          [3],
          [3]
        ]),
        equals([
          {3}
        ]));
  });
  test('RCO single-voter', () {
    expect(
        rankedChoiceOrder<int>([
          [1, 2, 3]
        ]),
        equals([
          [1],
          [2, 3]
        ]));
  });
  test('RCO symmetry', () {
    expect(
        rankedChoiceOrder<int>([
          [1, 2, 3],
          [3, 2, 1]
        ]),
        equals([
          [1, 3],
          [2]
        ]));
  });
  // from https://github.com/AnnikaCodes/betterpoll/blob/main/backend/src/poll.rs test
  test('annika1', () {
    expect(
        rankedChoiceOrder<String>([
          ["c", "a", "b"],
          ["a", "c", "b"],
          ["b", "c"]
        ]),
        equals([
          ["c", "a", "b"]
        ]));
  });
}
