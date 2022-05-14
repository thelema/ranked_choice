import "package:test/test.dart";
import "package:format/format.dart";

class PrefPos {
  final int voterIdx;
  int voteIdx;
  PrefPos(this.voterIdx, this.voteIdx);
  @override
  String toString() {
    return "Voter {} Vote {}".format(voterIdx, voteIdx);
  }
}

const intMax = 0x7fffffff; // 32-bit
const debug = false;

// returns the next
int getNextPref<T>(final List<T> voterVotes, int voteIdx, final Set<T> elims) {
  return voteIdx;
}

// Given many voters' preferences, compute ordering over things preferred induced by those preferences
// Items with equal preference will be in same sublist
List<Set<T>> rankedChoiceOrder<T>(final List<List<T>> votes) {
  // all values eliminated
  Set<T> elimSet = {};
  // ordering of eliminated values
  List<Set<T>> elims = [];
  // after eliminating various values, whose number 1 vote is for each value
  Map<T, List<PrefPos>> preferrers = {};

  addPref(PrefPos pp) {
    if (votes[pp.voterIdx].length > pp.voteIdx) {
      preferrers.putIfAbsent(votes[pp.voterIdx][pp.voteIdx], () => []).add(pp);
    }
  }

  // initialize preferrers to lists of indexes of voters who have each T as their 1st preference
  for (int ii = 0; ii < votes.length; ii++) {
    addPref(PrefPos(ii, 0));
  }
  if (debug) print("Prefs0: $preferrers");
  // add any values with no #1 votes as first elims (maybe could do better)
  Set<T> elim0 = {};
  votes.asMap().forEach((int index, List<T> value) {
    for (final val in value.skip(1)) {
      if (!preferrers.containsKey(val)) {
        elim0.add(val);
      }
    }
  });
  if (elim0.isNotEmpty) {
    elims.add(elim0.toSet());
    elimSet.addAll(elim0);
  }
  if (debug) print("First eliminations: $elim0");
  while (preferrers.isNotEmpty) {
    // identify all T that have lowest popularity
    List<MapEntry<T, List<PrefPos>>> lowPop = [];
    int minPop = intMax;
    for (var item in preferrers.entries) {
      final ipop = item.value.length;
      if (ipop < minPop) {
        lowPop.clear();
        minPop = ipop;
      }
      if (ipop <= minPop) {
        lowPop.add(item);
      }
    }
    if (debug) print("Lowest popularity: $lowPop");
    assert(lowPop.isNotEmpty);
    // anything tied for lowest is simultaneously eliminated
    elims.add(lowPop.map((e) => e.key).toSet());
    elimSet.addAll(elims.last);

    // Update preferrers that voted for eliminated candidates
    for (final me in lowPop) {
      // move all entries in lowPop into that voter's next preferred choice
      for (var lp in me.value) {
        final voterVotes = votes[lp.voterIdx];
        while (lp.voteIdx < voterVotes.length &&
            !elims.contains(voterVotes[lp.voteIdx])) {
          lp.voteIdx++;
        }
        addPref(lp);
      }
      preferrers.remove(me.key);
    }
    if (debug) print("Prefs: $preferrers");
  }

  return elims.reversed.toList();
}

void main() {
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
