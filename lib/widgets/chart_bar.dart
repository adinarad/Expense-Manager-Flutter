import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  final String _label;
  final double _spendingAmount;
  final double _spendingPctOfTotal;

  ChartBar(this._label, this._spendingAmount, this._spendingPctOfTotal);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Column(
        children: <Widget>[
          Container(
            height: constraints.maxHeight * 0.16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹${_spendingAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: "Quicksand",
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          SizedBox(
            height: constraints.maxHeight * 0.04,
          ),
          Container(
            height: constraints.maxHeight * 0.6,
            width: 10,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    color: Color.fromRGBO(220, 220, 220, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: _spendingPctOfTotal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: constraints.maxHeight * 0.04,
          ),
          Container(
            height: constraints.maxHeight * 0.16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _label,
                style: TextStyle(
                  fontFamily: "Quicksand",
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
