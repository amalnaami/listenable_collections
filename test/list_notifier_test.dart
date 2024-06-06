import 'package:flutter_test/flutter_test.dart';
import 'package:functional_listener/functional_listener.dart';

import '../lib/src/list_notifier.dart';

void main() {
  group("Tests for the ListNotifier's methods", () {
    late ListNotifier list;
    List result = [];

    setUp(() {
      list = ListNotifier(data: [1, 2, 3]);
      result.clear();
    });

    void buildListener() {
      list.addListener(() {
        result.addAll(list.value);
      });
    }

    test("Elements get swapped correctly", () {
      buildListener();

      list.swap(0, 2);

      /// Swap the values at these indexes
      expect(result, [3, 2, 1]);
    });

    test("list length and index's value", () {
      buildListener();

      final length = list.length;
      final firstItem = list[0];

      /// To get the length of the list
      expect(length, 3);

      /// To get value at index
      expect(firstItem, 1);
    });

    test("Listeners get updated if a value gets added", () {
      buildListener();

      list.add(4);

      /// Add value 4 to the end of the list
      expect(result[3], 4);
    });

    test("Listeners get notified if an iterable is added", () {
      buildListener();

      list.addAll([4, 5]);

      /// Add values 4 and 5 to the end of the list
      expect(result, [1, 2, 3, 4, 5]);
    });

    test("Listeners get notified if the list is cleared", () {
      buildListener();

      list.clear();

      /// Clear the list
      expect(result, []);
    });

    test("Listeners get notified on fillRange", () {
      buildListener();

      list.fillRange(0, list.length, 1);

      /// Fill the list with value(1) from index 0 to the end
      expect(result, [1, 1, 1]);
    });

    test("Listeners get notified on value insertion", () {
      buildListener();

      list.insert(1, 1);

      /// Insert value 1 at index 1 then complete the list
      expect(result, [1, 1, 2, 3]);
    });

    test("Listeners get notified on iterable insertion", () {
      buildListener();

      list.insertAll(1, [1, 2]);

      /// Insert values 1 and 2 at index 1 then complete the list
      expect(result, [1, 1, 2, 2, 3]);
    });

    test("Listeners get notified on value removal", () {
      buildListener();

      final itemIsRemoved = list.remove(2);

      /// remove(value): mean remove value 2 from the list
      expect(result, [1, 3]);

      /// Check if removed value is equal to 2
      expect(itemIsRemoved, true);
    });

    test("Listeners get notified on index removal", () {
      buildListener();

      final removedItem = list.removeAt(1);

      /// removeAt(index): mean remove value in the index 1 from the list
      expect(result, [1, 3]);

      /// Removed value at index 1 is equal to 2
      expect(removedItem, 2);
    });

    test("Listeners get notified on last element removal", () {
      buildListener();

      final itemRemoved = list.removeLast();

      /// Remove the last value from the list
      expect(result, [1, 2]);

      /// Removed value is equal to 3
      expect(itemRemoved, 3);
    });

    test("Listeners get notified on range removal", () {
      buildListener();

      list.removeRange(0, 2);

      /// Remove values from index 0 to before index 2
      expect(result, [3]);
    });

    test("Listeners get notified on removeWhere", () {
      buildListener();

      list.removeWhere((element) => element == 1);

      /// Remove all elements that are equal to 1
      expect(list.value, [2, 3]);
    });

    test("Listeners get notified on replaceRange", () {
      buildListener();

      list.replaceRange(0, 2, [3, 3]);
      /// Replace values from index 0 to before index 2 with [3, 3]
      /// if the replacement list is [3] the result will be [3, 3]
      /// if the replacement list is [3, 3, 3] the result will be [3, 3, 3, 3]
      expect(result, [3, 3, 3]);
    });

    test("Listeners get notified on retainWhere", () {
      buildListener();

      list.retainWhere((element) => element == 1);

      /// Retain all elements that verify the condition
      expect(list.value, [1]);
    });

    test("Listeners get notified on setAll", () {
      buildListener();

      list.setAll(2, [2]);

      /// Set all values from index 2 to the end with values in the newList
      /// index 2 is 3, so it will be replaced with 2
      /// if the list was [1, 2, 3] and we setAll(0, [5, 6]) it would be [5, 6, 3]
      /// if the list was [1, 2, 3] and we setAll(2, [5, 6]) it would be [1, 2, 5, 6]
      expect(list.value, [1, 2, 2]);
    });

    test("Listeners get notified on setRange", () {
      buildListener();

      list.setRange(2, list.length, [2]);

      /// Set values from index 2 to the end with values in the replacement list
      /// index 2 is 3, so it will be replaced with 2
      /// if setRange(0, 2, [5, 6]) it would be [5, 6, 3]
      /// [5,6] will replace [1,2] in the list [5, 6, 3]
      /// the replacement list should contain num of elements equal to the range
      /// if setRange(0, 2, [5, 6, 7]) it would be [5, 6, 7] as the replacement list
      expect(result, [1, 2, 2]);
    });

    test("Listeners get notified on shuffle", () {
      buildListener();

      list.shuffle();

      /// Shuffle the list
      expect(result != [1, 2, 3], true);
    });

    test("Listeners get notified on sort", () {
      buildListener();

      list.sort((value1, value2) => -(value1.compareTo(value2)));

      /// Sort the list in descending(-) order
      /// Sort the list regarding the condition
      expect(result, [3, 2, 1]);
    });
  });

  group("Tests for the ListNotifier's equality", () {
    List? result;

    setUp(() {
      result = null;
    });

    test("The listener isn't notified if the value is equal", () {
      final ListNotifier list = ListNotifier(
          data: [1, 2, 3], notificationMode: CustomNotifierMode.normal);

      list.addListener(() {
        result = [...list.value];
      });

      list[0] = 1;

      expect(result, null);
    });

    test("customEuqality works correctly", () {
      final ListNotifier list = ListNotifier(
        data: [1, 2, 3],
        notificationMode: CustomNotifierMode.normal,
        customEquality: (index, value) => value >= 3,
      );

      list.addListener(() {
        result = [...list.value];
      });

      list[2] = 3;

      expect(result, null);

      list[0] = 1;

      // if customEquality wasn't implemented this would not call
      // the listeners, it doea because 1 < 3, as defined in
      // custom equality.
      expect(result, [1, 2, 3]);
    });
  });
}
