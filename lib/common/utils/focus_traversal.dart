import "package:collection/collection.dart";
import 'package:flutter/material.dart';

class FocusListener {
  static final List<FocusListener> _listeners = <FocusListener>[];

  static void focusChanged(FocusGroup group, int row, int column) {
    for (var listener in _listeners) {
      listener.onFocusChanged(group, row, column);
    }
  }

  static void add(FocusListener listener) => _listeners.add(listener);
  static void remove(FocusListener listener) => _listeners.remove(listener);

  @protected
  void onFocusChanged(FocusGroup group, int row, int column) {}
}

enum FocusGroup { root, header, button, listRow, liveHeader }

class RecentFocusNode extends FocusNode implements Comparable<RecentFocusNode> {
  FocusGroup group;
  static RecentFocusNode? root;

  @override
  int compareTo(RecentFocusNode other) {
    // Example: compare by row, then by column
    if (row != other.row) {
      return row.compareTo(other.row);
    }
    return column.compareTo(other.column);
  }

  int visited = -1;
  int row = -1, column = -1;

  RecentFocusNode({required this.group}) {
    if (group == FocusGroup.root) {
      // 🔥 IMPORTANT: Always update root when a new root is created
      root = this;
    }
  }

  @override
  void dispose() {
    // 🔥 Clear root reference if this was the root
    if (group == FocusGroup.root && root == this) {
      debugPrint('🔴 ROOT DISPOSED: ${identityHashCode(this)}');
      root = null;
    }
    super.dispose();
  }
}

class RecentFocusTraversalPolicy extends FocusTraversalPolicy {
  static int visited = 0;
  static RecentFocusNode? latest;

  final FocusGroup group;

  const RecentFocusTraversalPolicy({required this.group});

  static void setFocus(FocusNode node, bool update) {
    if (node is RecentFocusNode) {
      debugPrint('\n==== setFocus CALLED ====');
      debugPrint(
        'Target -> group=${node.group}, row=${node.row}, col=${node.column}',
      );

      if (update) node.visited = visited++;

      node.requestFocus();

      Scrollable.ensureVisible(
        node.context!,
        alignment: 0.5,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        duration: const Duration(milliseconds: 250),
      );

      latest = node;
      FocusListener.focusChanged(node.group, node.row, node.column);

      debugDumpTree(); // 🔥 FULL TREE debugPrint
    }
  }

  static void moveToHeader() {
    final nodes = RecentFocusNode.root?.descendants
        .whereType<RecentFocusNode>()
        .where((n) => n.group == FocusGroup.header)
        .toList();

    if (nodes == null || nodes.isEmpty) {
      debugPrint('⚠️ moveToHeader: no header nodes');
      return;
    }

    nodes.sort(_orderByRecentVisit);
    setFocus(nodes.first, false);
  }

  static void moveToListRow() {
    final nodes = RecentFocusNode.root?.descendants
        .whereType<RecentFocusNode>()
        .where((n) => n.group == FocusGroup.listRow)
        .toList();

    if (nodes == null || nodes.isEmpty) {
      debugPrint('⚠️ moveToListRow: no listRow nodes');
      return;
    }

    nodes.sort(_orderByRecentVisit);
    setFocus(nodes.first, false);
  }

  @override
  FocusNode findFirstFocusInDirection(
    FocusNode currentNode,
    TraversalDirection direction,
  ) {
    return FocusNode();
  }

  @override
  FocusNode? findFirstFocus(
    FocusNode currentNode, {
    bool ignoreCurrentFocus = false,
  }) {
    return FocusNode();
  }

  static void moveToHeaderStart() {
    debugPrint('\n=== moveToHeaderStart ===');

    final nodes = RecentFocusNode.root?.descendants
        .whereType<RecentFocusNode>()
        .toList();

    if (nodes == null) {
      debugPrint('NO ROOT NODES');
      return;
    }

    debugPrint('ALL NODES:');
    for (final n in nodes) {
      debugPrint('  ${n.group} row=${n.row} col=${n.column}');
    }

    final buttons = nodes.where((n) => n.group == FocusGroup.button).toList();

    debugPrint('\nBUTTON NODES FOUND = ${buttons.length}');
    for (final b in buttons) {
      debugPrint('  BUTTON -> row=${b.row} col=${b.column}');
    }

    if (buttons.isNotEmpty) {
      setFocus(buttons.first, true);
    } else {
      debugPrint('NO BUTTON → FALLBACK TO HEADER');
      moveToHeader();
    }
  }

  static void debugDumpTree() {
    debugPrint('\n=========== FOCUS TREE DUMP ===========');
    final nodes = RecentFocusNode.root?.descendants
        .whereType<RecentFocusNode>()
        .toList();

    if (nodes == null) {
      debugPrint('NO ROOT');
      return;
    }

    for (final n in nodes) {
      debugPrint(
        'Node -> group=${n.group}, row=${n.row}, col=${n.column}, visited=${n.visited}',
      );
    }
    debugPrint('======================================\n');
  }

  bool handleGroupNavigation(
    FocusNode currentNode,
    TraversalDirection direction,
    Iterable<FocusNode> nodes,
  ) {
    if (group == FocusGroup.header) {
      switch (direction) {
        case TraversalDirection.left:
          if (nodes.first != currentNode) {
            // Use the sorted nodes list instead of searching by position
            _moveToAdjacentNode(currentNode, nodes.toList(), -1);
          }
          break;
        case TraversalDirection.right:
          if (nodes.last != currentNode) {
            // Use the sorted nodes list instead of searching by position
            _moveToAdjacentNode(currentNode, nodes.toList(), 1);
          }
          break;
        case TraversalDirection.up:
          debugPrint('-----------------_SACHIN');
          moveToHeader(); // go to tabs
          break;
        case TraversalDirection.down:
          // 1) Try button first
          final buttons = RecentFocusNode.root?.descendants
              .whereType<RecentFocusNode>()
              .where((n) => n.group == FocusGroup.button)
              .toList();

          if (buttons != null && buttons.isNotEmpty) {
            debugPrint('HEADER ↓ → PLAY BUTTON');
            setFocus(buttons.first, true);
          } else {
            debugPrint('HEADER ↓ → LIST ROW (no button)');
            moveToListRow();
          }
          break;
      }
    } else if (group == FocusGroup.liveHeader) {
      switch (direction) {
        case TraversalDirection.left:
          _moveToAdjacentNode(currentNode, nodes.toList(), -1);
          break;

        case TraversalDirection.right:
          _moveToAdjacentNode(currentNode, nodes.toList(), 1);
          break;

        case TraversalDirection.up:
          // 🔥 go to button first
          final buttons = RecentFocusNode.root?.descendants
              .whereType<RecentFocusNode>()
              .where((n) => n.group == FocusGroup.button)
              .toList();

          if (buttons != null && buttons.isNotEmpty) {
            buttons.sort((a, b) => a.row.compareTo(b.row));
            debugPrint('LIVE HEADER ↑ → BUTTON');
            setFocus(buttons.last, true); // nearest button
          } else {
            // fallback to header
            final headers = RecentFocusNode.root?.descendants
                .whereType<RecentFocusNode>()
                .where((n) => n.group == FocusGroup.header)
                .toList();

            if (headers != null && headers.isNotEmpty) {
              headers.sort((a, b) => a.column.compareTo(b.column));
              debugPrint('LIVE HEADER ↑ → HEADER');
              setFocus(headers.first, true);
            }
          }
          break;

        case TraversalDirection.down:
          // Go to the FIRST listRow below liveHeader
          final listRows = RecentFocusNode.root?.descendants
              .whereType<RecentFocusNode>()
              .where((n) => n.group == FocusGroup.listRow)
              .toList();

          if (listRows == null || listRows.isEmpty) return true;

          // Sort by row (top → bottom)
          listRows.sort((a, b) => a.row.compareTo(b.row));

          // pick smallest row > liveHeader row
          final liveRow = (currentNode as RecentFocusNode).row;

          final target =
              listRows.firstWhereOrNull((n) => n.row > liveRow) ??
              listRows.first;

          setFocus(target, true);
          break;
      }
    } else if (group == FocusGroup.button) {
      debugPrint('🔵 BUTTON GROUP NAVIGATION TRIGGERED');

      final buttons = RecentFocusNode.root?.descendants
          .whereType<RecentFocusNode>()
          .where((n) => n.group == FocusGroup.button)
          .toList();

      if (buttons == null || buttons.isEmpty) return true;

      // Sort vertically by row (top → bottom)
      buttons.sort((a, b) => a.row.compareTo(b.row));

      // 🔹 SINGLE BUTTON MODE (backward compatible)
      if (buttons.length == 1) {
        debugPrint('🔵 SINGLE BUTTON MODE');
        switch (direction) {
          case TraversalDirection.up:
            debugPrint('SINGLE BUTTON ↑ → HEADER');
            moveToHeader();
            break;

          case TraversalDirection.down:
            debugPrint('SINGLE BUTTON ↓ → LIST ROW');
            moveToListRow();
            break;

          case TraversalDirection.left:
          case TraversalDirection.right:
            debugPrint('SINGLE BUTTON ←/→ ignored');
            break;
        }
        return true;
      }

      // 🔹 MULTI BUTTON MODE (dynamic)
      if (currentNode is! RecentFocusNode) return true;

      final index = buttons.indexOf(currentNode);

      switch (direction) {
        case TraversalDirection.up:
          if (index > 0) {
            debugPrint('BUTTON ↑ → BUTTON');
            setFocus(buttons[index - 1], true); // button to button
          } else {
            debugPrint('TOP BUTTON ↑ → HEADER');
            moveToHeader(); // top → header
          }
          break;

        case TraversalDirection.down:
          if (index < buttons.length - 1) {
            debugPrint('BUTTON ↓ → BUTTON');
            setFocus(buttons[index + 1], true);
          } else {
            // 🔥 check liveHeader first
            final liveHeaders = RecentFocusNode.root?.descendants
                .whereType<RecentFocusNode>()
                .where((n) => n.group == FocusGroup.liveHeader)
                .toList();

            if (liveHeaders != null && liveHeaders.isNotEmpty) {
              liveHeaders.sort((a, b) => a.row.compareTo(b.row));
              debugPrint('BUTTON ↓ → LIVE HEADER');
              setFocus(liveHeaders.first, true);
            } else {
              debugPrint('BUTTON ↓ → LIST ROW');
              moveToListRow();
            }
          }
          break;

        case TraversalDirection.left:
        case TraversalDirection.right:
          debugPrint('BUTTON ←/→ ignored');
          break;
      }

      return true;
    } else {
      // horizontal
      switch (direction) {
        case TraversalDirection.left:
          if (nodes.first != currentNode) {
            moveFocus(currentNode, direction);
          }
          break;

        case TraversalDirection.right:
          if (nodes.last != currentNode) {
            moveFocus(currentNode, direction);
          }
          break;
        case TraversalDirection.up:
          debugPrint('-----------------_SACHIN');
          debugPrint('--- UP PRESSED ---');

          final node = currentNode as RecentFocusNode;

          /* =========================================
           1️⃣ NORMAL LISTROW MOVE FIRST
            ========================================= */

          final listRows = RecentFocusNode.root?.descendants
              .whereType<RecentFocusNode>()
              .where((n) => n.group == FocusGroup.listRow)
              .toList();

          if (listRows != null && listRows.isNotEmpty) {
            // rows above current
            final rowsAbove = listRows.where((n) => n.row < node.row).toList();

            if (rowsAbove.isNotEmpty) {
              // nearest row above
              rowsAbove.sort((a, b) => b.row.compareTo(a.row));
              final targetRow = rowsAbove.first.row;

              final sameRowNodes = listRows
                  .where((n) => n.row == targetRow)
                  .toList();

              sameRowNodes.sort((a, b) => a.column.compareTo(b.column));

              debugPrint('LIST ↑ → LISTROW $targetRow');
              setFocus(sameRowNodes.first, true);
              break; // ✅ STOP HERE
            }
          }

          /* =========================================
          2️⃣ LIVE HEADER (ONLY IF NO LISTROW ABOVE)
          ========================================= */

          final liveHeaders = RecentFocusNode.root?.descendants
              .whereType<RecentFocusNode>()
              .where((n) => n.group == FocusGroup.liveHeader)
              .toList();

          if (liveHeaders != null && liveHeaders.isNotEmpty) {
            final candidates = liveHeaders
                .where((n) => n.rect.bottom <= node.rect.top)
                .toList();

            if (candidates.isNotEmpty) {
              candidates.sort((a, b) => b.rect.top.compareTo(a.rect.top));
              debugPrint('LIST ↑ → LIVE HEADER');
              setFocus(candidates.first, true);
              break;
            }
          }

          /* =========================================
          3️⃣ ORIGINAL ROOT BEHAVIOR
          ========================================= */

          if (node.row == 0) {
            final buttons = RecentFocusNode.root?.descendants
                .whereType<RecentFocusNode>()
                .where((n) => n.group == FocusGroup.button)
                .toList();

            if (buttons != null && buttons.isNotEmpty) {
              buttons.sort((a, b) => a.row.compareTo(b.row));
              debugPrint('LIST ↑ → BOTTOM BUTTON');
              setFocus(buttons.last, true);
            } else {
              debugPrint('LIST ↑ → HEADER');
              moveToHeader();
            }
          } else {
            _moveToNextListRow(currentNode, -1);
          }

          break;

        case TraversalDirection.down:
          _moveToNextListRow(currentNode, 1);
          break;
      }
    }

    return true;
  }

  void _moveToAdjacentNode(
    FocusNode currentNode,
    List<FocusNode> sortedNodes,
    int offset,
  ) {
    if (sortedNodes.isEmpty) return;

    final currentIndex = sortedNodes.indexOf(currentNode);
    if (currentIndex == -1) return;

    final nextIndex = currentIndex + offset;

    if (nextIndex < 0 || nextIndex >= sortedNodes.length) {
      debugPrint('⛔ No horizontal target');
      return;
    }

    final next = sortedNodes[nextIndex];
    if (next is RecentFocusNode) {
      setFocus(next, true);
    }
  }

  static int _orderByRecentVisit(Object a, Object b) {
    if (a is RecentFocusNode && b is RecentFocusNode) {
      return b.visited - a.visited;
    } else {
      return 0;
    }
  }

  void _moveToNextListRow(FocusNode node, int diff) {
    debugPrint('--- _moveToNextListRow CALLED ---');

    if (node is! RecentFocusNode) return;

    final nodes = RecentFocusNode.root?.descendants
        .whereType<RecentFocusNode>()
        .where((n) => n.group == FocusGroup.listRow)
        .toList();

    if (nodes == null || nodes.isEmpty) {
      debugPrint('⚠️ No listRow nodes');
      return;
    }

    final maxRow = nodes.map((n) => n.row).reduce((a, b) => a > b ? a : b);

    var nextRow = node.row + diff;
    if (nextRow < 0 || nextRow > maxRow) {
      debugPrint('⛔ No row in that direction');
      return; // ✅ Netflix: stop, no jump
    }

    final sameRowNodes = nodes.where((n) => n.row == nextRow).toList();

    if (sameRowNodes.isEmpty) {
      debugPrint('⚠️ No nodes in row $nextRow');
      return;
    }

    // ✅ Netflix behavior: always first item
    sameRowNodes.sort((a, b) => a.column.compareTo(b.column));
    final target = sameRowNodes.first;

    debugPrint('NETFLIX TARGET -> row=${target.row}, col=${target.column}');
    setFocus(target, true);
  }

  void moveFocus(FocusNode node, TraversalDirection direction) {
    debugPrint('moveFocus called: direction=$direction');
    var candidates = node.parent?.traversalDescendants
        .where((element) => element != node)
        .toList();

    if (candidates != null) {
      debugPrint('  Found ${candidates.length} candidates');
      _moveFocus(node, direction, candidates);
    }
  }

  int _orderByVertical(FocusNode a, FocusNode b) {
    return (a.rect.top - b.rect.top).toInt();
  }

  int _descendingOrderByVertical(FocusNode a, FocusNode b) {
    return (b.rect.top - a.rect.top).toInt();
  }

  int _orderByHorizontal(FocusNode a, FocusNode b) {
    return (a.rect.left - b.rect.left).toInt();
  }

  int _descendingOrderByHorizontal(FocusNode a, FocusNode b) {
    return (b.rect.left - a.rect.left).toInt();
  }

  FocusNode _selectNode(
    FocusNode node,
    TraversalDirection direction,
    List<FocusNode> candidates,
  ) {
    debugPrint(
      '_selectNode: direction=$direction, node.rect=${node.rect}, candidates=${candidates.length}',
    );

    switch (direction) {
      case TraversalDirection.up:
        debugPrint('-----------------_SACHIN');
        candidates = candidates
            .where((n) => n.rect.bottom < node.rect.top)
            .sorted(_descendingOrderByVertical)
            .toList();
        break;
      case TraversalDirection.down:
        candidates = candidates
            .where((n) => n.rect.top > node.rect.bottom)
            .sorted(_orderByVertical)
            .toList();
        break;
      case TraversalDirection.left:
        candidates = candidates
            .where((n) => n.rect.right < node.rect.left)
            .sorted(_descendingOrderByHorizontal)
            .toList();
        debugPrint('  After filtering LEFT: ${candidates.length} candidates');
        for (var c in candidates) {
          if (c is RecentFocusNode) {
            debugPrint(
              '    Candidate: column=${c.column}, rect.right=${c.rect.right} < node.rect.left=${node.rect.left}',
            );
          }
        }
        break;
      case TraversalDirection.right:
        candidates = candidates
            .where((n) => n.rect.left > node.rect.right)
            .sorted(_orderByHorizontal)
            .toList();
        debugPrint('  After filtering RIGHT: ${candidates.length} candidates');
        for (var c in candidates) {
          if (c is RecentFocusNode) {
            debugPrint(
              '    Candidate: column=${c.column}, rect.left=${c.rect.left} > node.rect.right=${node.rect.right}',
            );
          }
        }
        break;
    }

    var selected = candidates.isEmpty ? node : candidates.first;
    if (selected is RecentFocusNode) {
      debugPrint('  Selected node: column=${selected.column}');
    }
    return selected;
  }

  FocusNode _moveFocus(
    FocusNode node,
    TraversalDirection direction,
    List<FocusNode> candidates,
  ) {
    final next = _selectNode(node, direction, candidates);
    if (next == node) return node;

    setFocus(next as RecentFocusNode, true);
    return next;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    debugPrint('\n===== KEY EVENT =====');
    debugPrint('Direction = $direction');

    if (currentNode is RecentFocusNode) {
      debugPrint(
        'Current -> group=${currentNode.group}, row=${currentNode.row}, col=${currentNode.column}',
      );
    } else {
      debugPrint('Current -> NOT RecentFocusNode');
    }

    final parent = currentNode.parent;
    if (parent != null) {
      debugPrint('Parent = ${parent.runtimeType}');
      var nodes = sortDescendants(parent.children, currentNode);
      debugPrint(
        'Children scope: ${nodes.map((n) => n is RecentFocusNode ? "${n.group}:${n.row}:${n.column}" : "X")}',
      );
      handleGroupNavigation(currentNode, direction, nodes);
    } else {
      debugPrint('NO PARENT');
    }

    return true;
  }

  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    debugPrint('sortDescendants called for ${descendants.length} nodes');
    for (var n in descendants) {
      if (n is RecentFocusNode) {
        debugPrint(
          '  Node: row=${n.row}, column=${n.column}, offset.dx=${n.offset.dx}',
        );
      }
    }

    // Sort by screen position
    // Header is horizontal, so sort by dx (horizontal position)
    // ListRow is also horizontal, so sort by dx
    var sorted = descendants.toList()
      ..sort((a, b) => (a.offset.dx - b.offset.dx).toInt());

    debugPrint('After sorting:');
    for (var n in sorted) {
      if (n is RecentFocusNode) {
        debugPrint(
          '  Node: row=${n.row}, column=${n.column}, offset.dx=${n.offset.dx}',
        );
      }
    }

    return sorted;
  }
}
