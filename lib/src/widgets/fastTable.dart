import 'package:flutter/material.dart';

class FastDataTableWidget extends StatelessWidget {
  static const double rowHeight = 100;
  final List<List<String>> rows;
  final Function(int x, int y) onTap;
  final double textScaler;

  // TODO add a feature where it checks all the fields orders them by length and assigns them different sizes based on how many letters the biggest cell had.

  const FastDataTableWidget(
      {super.key,
      required this.rows,
      required this.onTap,
      this.textScaler = 2});

  static ({T1 x, T2 y})? getCellData<T1, T2>(
    int x,
    int y,
    int headerRows,
    List<T1> xValues,
    List<T2> yValues,
  ) {
    T1 xValue = xValues[x];
    final a = (y % (headerRows + yValues.length)) - headerRows;
    if (0 <= a && a < yValues.length) {
      T2 yValue = yValues[a];
      return (x: xValue, y: yValue);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (details) {
          final y = details.localPosition.dy ~/ rowHeight;
          final items = rows[y];
          final x = details.localPosition.dx ~/
              (constraints.biggest.width / items.length);
          onTap(x, y);
        },
        child: CustomPaint(
          painter: TablePainter(rows: rows, textScaler: textScaler),
          size: Size(double.infinity, rowHeight * rows.length),
        ),
      );
    });
  }
}

class TablePainter extends CustomPainter {
  static const double padding = 30;
  final List<List<String>> rows;
  final double textScaler;
  const TablePainter({required this.rows, required this.textScaler});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    for (var i = 0; i < rows.length; i++) {
      for (var j = 0; j < rows[i].length; j++) {
        TextSpan span = TextSpan(text: rows[i][j]);
        final itemWidth = (size.width / rows[i].length);
        final x = itemWidth * j;
        final y = FastDataTableWidget.rowHeight * i;
        TextPainter(
          text: span,
          textScaleFactor: textScaler / rows[i].length,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        )
          ..layout(maxWidth: itemWidth - padding * 2)
          ..paint(
            canvas,
            Offset(x + padding, y + padding),
          );
        canvas.drawLine(Offset(x, y), Offset(x + itemWidth, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(TablePainter oldDelegate) => rows != oldDelegate.rows;

  @override
  bool shouldRebuildSemantics(TablePainter oldDelegate) => false;
}
