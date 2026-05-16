// import 'package:flutter/material.dart';

// // ─── Data Models ─────────────────────────────────────────────────────────────

// class HostelData {
//   final String title;
//   final int totalNum, totalAmt, paidNum, paidAmt;
//   const HostelData({
//     required this.title,
//     required this.totalNum,
//     required this.totalAmt,
//     required this.paidNum,
//     required this.paidAmt,
//   });
//   int get balanceNum => totalNum - paidNum;
//   int get balanceAmt => totalAmt - paidAmt;
// }

// class LedgerRow {
//   String desc;
//   Map<int, double> credit; // key = day (1–31)
//   Map<int, double> debit;

//   LedgerRow({required this.desc}) : credit = {}, debit = {};

//   double get totalCredit => credit.values.fold(0, (s, v) => s + v);
//   double get totalDebit => debit.values.fold(0, (s, v) => s + v);
//   double get balance => totalCredit - totalDebit;
// }

// // ─── Constants ───────────────────────────────────────────────────────────────

// const _kDark = Color(0xFF1A1A2E);
// const _kGreen = Color(0xFF2E7D32);
// const _kGreenDk = Color(0xFF1B5E20);
// const _kRed = Color(0xFFC62828);
// const _kRedDk = Color(0xFFB71C1C);
// const _kGreenBg = Color(0xFFE8F5E9);
// const _kRedBg = Color(0xFFFFEBEE);
// const _kHeaderBg = Color(0xFFEEEEEE);
// const _kSubHdrBg = Color(0xFFF5F5F5);
// const _kBorderC = Color(0xFF9E9E9E);

// // cell widths
// const double _descW = 110;
// const double _cellW = 48; // Cr or Dr
// const double _balW = 68;
// const double _rowH = 36.0;
// const double _hdrH = 28.0;

// final Map<String, HostelData> _hostels = {
//   'mortel4': const HostelData(
//     title: 'Hi Tech',
//     totalNum: 140,
//     totalAmt: 5000,
//     paidNum: 86,
//     paidAmt: 3200,
//   ),
//   'mortel5': const HostelData(
//     title: 'Hi Tech 1',
//     totalNum: 200,
//     totalAmt: 8000,
//     paidNum: 120,
//     paidAmt: 4800,
//   ),
//   'sunrise': const HostelData(
//     title: 'Hi Tech 2',
//     totalNum: 80,
//     totalAmt: 3200,
//     paidNum: 50,
//     paidAmt: 2000,
//   ),
//   'green': const HostelData(
//     title: 'Hi Tech 3',
//     totalNum: 60,
//     totalAmt: 2400,
//     paidNum: 40,
//     paidAmt: 1600,
//   ),
// };

// const _defaultRowNames = ['Rent', 'Mess fees', 'Electricity', 'Maintenance'];

// const _months = [
//   'January',
//   'February',
//   'March',
//   'April',
//   'May',
//   'June',
//   'July',
//   'August',
//   'September',
//   'October',
//   'November',
//   'December',
// ];

// int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

// // ─── Main Screen ─────────────────────────────────────────────────────────────

// class Analysis extends StatefulWidget {
//   const Analysis({super.key});

//   @override
//   State<Analysis> createState() => _AnalysisState();
// }

// class _AnalysisState extends State<Analysis> {
//   String _selectedHostel = 'mortel4';
//   int _curYear = DateTime.now().year;
//   int _curMonth = DateTime.now().month - 1; // 0-indexed

//   final List<LedgerRow> _rows = List.generate(
//     _defaultRowNames.length,
//     (i) => LedgerRow(desc: _defaultRowNames[i]),
//   );

//   HostelData get _hostel => _hostels[_selectedHostel]!;
//   int get _days => _daysInMonth(_curYear, _curMonth);

//   void _shiftMonth(int dir) {
//     setState(() {
//       _curMonth += dir;
//       if (_curMonth > 11) {
//         _curMonth = 0;
//         _curYear++;
//       }
//       if (_curMonth < 0) {
//         _curMonth = 11;
//         _curYear--;
//       }
//     });
//   }

//   Future<void> _addRow() async {
//     final ctrl = TextEditingController();
//     final name = await showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add row'),
//         content: TextField(
//           controller: ctrl,
//           autofocus: true,
//           decoration: const InputDecoration(hintText: 'Enter description'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, ctrl.text.trim()),
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//     if (name != null && name.isNotEmpty) {
//       setState(() => _rows.add(LedgerRow(desc: name)));
//     }
//   }

//   void _deleteRow(int i) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete row'),
//         content: Text('Delete "${_rows[i].desc}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() => _rows.removeAt(i));
//             },
//             child: const Text('Delete', style: TextStyle(color: _kRed)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _HostelDropdown(
//               value: _selectedHostel,
//               hostels: _hostels,
//               onChanged: (v) => setState(() => _selectedHostel = v!),
//             ),
//             const SizedBox(height: 12),
//             _SummaryCard(hostel: _hostel),
//             const SizedBox(height: 12),
//             _LedgerCard(
//               rows: _rows,
//               year: _curYear,
//               month: _curMonth,
//               days: _days,
//               onPrevMonth: () => _shiftMonth(-1),
//               onNextMonth: () => _shiftMonth(1),
//               onAddRow: _addRow,
//               onDeleteRow: _deleteRow,
//               onChanged: () => setState(() {}),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Hostel Dropdown ──────────────────────────────────────────────────────────

// class _HostelDropdown extends StatelessWidget {
//   final String value;
//   final Map<String, HostelData> hostels;
//   final ValueChanged<String?> onChanged;
//   const _HostelDropdown({
//     required this.value,
//     required this.hostels,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.black26),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           icon: const Icon(Icons.keyboard_arrow_down),
//           items: hostels.entries
//               .map(
//                 (e) =>
//                     DropdownMenuItem(value: e.key, child: Text(e.value.title)),
//               )
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }

// // ─── Summary Card ─────────────────────────────────────────────────────────────

// class _SummaryCard extends StatelessWidget {
//   final HostelData hostel;
//   const _SummaryCard({required this.hostel});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black87, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             decoration: const BoxDecoration(
//               color: _kDark,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//             ),
//             child: Text(
//               hostel.title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//               ),
//             ),
//           ),
//           IntrinsicHeight(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _SummaryItem(
//                     'TOTAL',
//                     hostel.totalNum,
//                     hostel.totalAmt,
//                     _kDark,
//                   ),
//                 ),
//                 const VerticalDivider(width: 1, color: Colors.black26),
//                 Expanded(
//                   child: _SummaryItem(
//                     'PAID',
//                     hostel.paidNum,
//                     hostel.paidAmt,
//                     _kGreen,
//                   ),
//                 ),
//                 const VerticalDivider(width: 1, color: Colors.black26),
//                 Expanded(
//                   child: _SummaryItem(
//                     'BALANCE',
//                     hostel.balanceNum,
//                     hostel.balanceAmt,
//                     _kRed,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryItem extends StatelessWidget {
//   final String label;
//   final int num, amt;
//   final Color color;
//   const _SummaryItem(this.label, this.num, this.amt, this.color);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//       child: Column(
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: color,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.8,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '$num',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             '₹$amt',
//             style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Ledger Card ─────────────────────────────────────────────────────────────

// class _LedgerCard extends StatelessWidget {
//   final List<LedgerRow> rows;
//   final int year, month, days;
//   final VoidCallback onPrevMonth, onNextMonth, onAddRow;
//   final void Function(int) onDeleteRow;
//   final VoidCallback onChanged;

//   const _LedgerCard({
//     required this.rows,
//     required this.year,
//     required this.month,
//     required this.days,
//     required this.onPrevMonth,
//     required this.onNextMonth,
//     required this.onAddRow,
//     required this.onDeleteRow,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black87, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // month nav header
//           Container(
//             decoration: const BoxDecoration(
//               color: _kDark,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.chevron_left, color: Colors.white),
//                   onPressed: onPrevMonth,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//                 Text(
//                   'Ledger ${_months[month]} $year',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.chevron_right, color: Colors.white),
//                   onPressed: onNextMonth,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             child: Text(
//               'Scroll right for all days  ·  long-press row to delete',
//               style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//             ),
//           ),

//           // the grid
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: _LedgerGrid(
//               rows: rows,
//               days: days,
//               onDeleteRow: onDeleteRow,
//               onChanged: onChanged,
//             ),
//           ),

//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: OutlinedButton.icon(
//               onPressed: onAddRow,
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add row'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _kDark,
//                 side: const BorderSide(color: _kDark),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Ledger Grid (Row/Column based — no Table widget) ────────────────────────

// class _LedgerGrid extends StatelessWidget {
//   final List<LedgerRow> rows;
//   final int days;
//   final void Function(int) onDeleteRow;
//   final VoidCallback onChanged;

//   const _LedgerGrid({
//     required this.rows,
//     required this.days,
//     required this.onDeleteRow,
//     required this.onChanged,
//   });

//   // thin border side
//   static const BorderSide _b = BorderSide(color: _kBorderC, width: 0.8);

//   @override
//   Widget build(BuildContext context) {
//     final crTotals = List.generate(
//       days + 1,
//       (d) => rows.fold<double>(0, (s, r) => s + (r.credit[d] ?? 0)),
//     );
//     final drTotals = List.generate(
//       days + 1,
//       (d) => rows.fold<double>(0, (s, r) => s + (r.debit[d] ?? 0)),
//     );
//     final grandBal = rows.fold<double>(0, (s, r) => s + r.balance);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Header row 1: Description | Day1 Day2 … | Balance
//         Row(
//           children: [
//             _hdrCell(
//               'Description',
//               width: _descW,
//               height: _hdrH,
//               bg: _kHeaderBg,
//               border: const Border(right: _b, bottom: _b),
//             ),
//             for (int d = 1; d <= days; d++)
//               _hdrCell(
//                 'Day $d',
//                 width: _cellW * 2,
//                 height: _hdrH,
//                 bg: _kHeaderBg,
//                 border: const Border(right: _b, bottom: _b),
//               ),
//             _hdrCell(
//               'Balance',
//               width: _balW,
//               height: _hdrH,
//               bg: _kHeaderBg,
//               border: const Border(bottom: _b),
//             ),
//           ],
//         ),

//         // ── Header row 2: (empty) | Cr Dr Cr Dr … | (empty)
//         Row(
//           children: [
//             // spacer under "Description"
//             _hdrCell(
//               '',
//               width: _descW,
//               height: _hdrH,
//               bg: _kSubHdrBg,
//               border: const Border(right: _b, bottom: _b),
//             ),
//             for (int d = 1; d <= days; d++) ...[
//               _hdrCell(
//                 'Cr',
//                 width: _cellW,
//                 height: _hdrH,
//                 bg: _kSubHdrBg,
//                 textColor: _kGreenDk,
//                 border: const Border(right: _b, bottom: _b),
//               ),
//               _hdrCell(
//                 'Dr',
//                 width: _cellW,
//                 height: _hdrH,
//                 bg: _kSubHdrBg,
//                 textColor: _kRedDk,
//                 border: const Border(right: _b, bottom: _b),
//               ),
//             ],
//             // spacer under "Balance"
//             _hdrCell(
//               '',
//               width: _balW,
//               height: _hdrH,
//               bg: _kSubHdrBg,
//               border: const Border(bottom: _b),
//             ),
//           ],
//         ),

//         // ── Data rows
//         for (int i = 0; i < rows.length; i++)
//           Row(
//             children: [
//               // description — long-press to delete
//               GestureDetector(
//                 onLongPress: () => onDeleteRow(i),
//                 child: Container(
//                   width: _descW,
//                   height: _rowH,
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: const BoxDecoration(
//                     color: _kSubHdrBg,
//                     border: Border(right: _b, bottom: _b),
//                   ),
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     rows[i].desc,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ),
//               // Cr / Dr cells
//               for (int d = 1; d <= days; d++) ...[
//                 _EditCell(
//                   width: _cellW,
//                   height: _rowH,
//                   value: rows[i].credit[d],
//                   bgColor: Colors.white,
//                   focusBg: _kGreenBg,
//                   border: const Border(right: _b, bottom: _b),
//                   onChanged: (v) {
//                     rows[i].credit[d] = v;
//                     onChanged();
//                   },
//                 ),
//                 _EditCell(
//                   width: _cellW,
//                   height: _rowH,
//                   value: rows[i].debit[d],
//                   bgColor: Colors.white,
//                   focusBg: _kRedBg,
//                   border: const Border(right: _b, bottom: _b),
//                   onChanged: (v) {
//                     rows[i].debit[d] = v;
//                     onChanged();
//                   },
//                 ),
//               ],
//               // row balance
//               Container(
//                 width: _balW,
//                 height: _rowH,
//                 decoration: const BoxDecoration(
//                   color: _kSubHdrBg,
//                   border: Border(bottom: _b),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   '₹${rows[i].balance.toStringAsFixed(0)}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: rows[i].balance >= 0 ? _kGreenDk : _kRedDk,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//         // ── Totals footer row
//         Row(
//           children: [
//             Container(
//               width: _descW,
//               height: _rowH,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: const BoxDecoration(
//                 color: _kHeaderBg,
//                 border: Border(right: _b, top: _b),
//               ),
//               alignment: Alignment.centerLeft,
//               child: const Text(
//                 'Totals',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//               ),
//             ),
//             for (int d = 1; d <= days; d++) ...[
//               _totalCell(crTotals[d], _kGreenDk, _cellW),
//               _totalCell(drTotals[d], _kRedDk, _cellW),
//             ],
//             Container(
//               width: _balW,
//               height: _rowH,
//               decoration: const BoxDecoration(
//                 color: _kHeaderBg,
//                 border: Border(top: _b),
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 '₹${grandBal.toStringAsFixed(0)}',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: grandBal >= 0 ? _kGreenDk : _kRedDk,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _hdrCell(
//     String text, {
//     required double width,
//     required double height,
//     required Color bg,
//     Color? textColor,
//     required Border border,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(color: bg, border: border),
//       alignment: Alignment.center,
//       child: text.isEmpty
//           ? const SizedBox.shrink()
//           : Text(
//               text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//                 color: textColor ?? Colors.black87,
//               ),
//             ),
//     );
//   }

//   Widget _totalCell(double val, Color color, double width) {
//     return Container(
//       width: width,
//       height: _rowH,
//       decoration: const BoxDecoration(
//         color: _kHeaderBg,
//         border: Border(right: _b, top: _b),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         val > 0 ? val.toStringAsFixed(0) : '',
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }
// }

// // ─── Editable Cell ────────────────────────────────────────────────────────────

// class _EditCell extends StatefulWidget {
//   final double? value;
//   final double width, height;
//   final Color bgColor, focusBg;
//   final Border border;
//   final ValueChanged<double> onChanged;

//   const _EditCell({
//     required this.value,
//     required this.width,
//     required this.height,
//     required this.bgColor,
//     required this.focusBg,
//     required this.border,
//     required this.onChanged,
//   });

//   @override
//   State<_EditCell> createState() => _EditCellState();
// }

// class _EditCellState extends State<_EditCell> {
//   late final TextEditingController _ctrl;
//   late final FocusNode _focus;
//   bool _hasFocus = false;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = TextEditingController(
//       text: widget.value != null ? widget.value!.toStringAsFixed(0) : '',
//     );
//     _focus = FocusNode()
//       ..addListener(() {
//         setState(() => _hasFocus = _focus.hasFocus);
//       });
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     _focus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width,
//       height: widget.height,
//       decoration: BoxDecoration(
//         color: _hasFocus ? widget.focusBg : widget.bgColor,
//         border: widget.border,
//       ),
//       child: TextField(
//         controller: _ctrl,
//         focusNode: _focus,
//         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 12),
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           isDense: true,
//           contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
//           hintText: '—',
//           hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
//         ),
//         onChanged: (v) {
//           final parsed = double.tryParse(v);
//           if (parsed != null) widget.onChanged(parsed);
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class HostelData {
  final String title;
  final int totalNum, totalAmt, paidNum, paidAmt;
  const HostelData({
    required this.title,
    required this.totalNum,
    required this.totalAmt,
    required this.paidNum,
    required this.paidAmt,
  });
  int get balanceNum => totalNum - paidNum;
  int get balanceAmt => totalAmt - paidAmt;
}

class DebitEntry {
  String description;
  double amount;
  DebitEntry({required this.description, required this.amount});
}

class LedgerRow {
  // key = day (1–31)
  Map<int, double> credit;
  Map<int, List<DebitEntry>> debitEntries;

  LedgerRow() : credit = {}, debitEntries = {};

  double debitTotal(int day) =>
      (debitEntries[day] ?? []).fold(0, (s, e) => s + e.amount);

  double get totalCredit => credit.values.fold(0, (s, v) => s + v);
  double totalDebitAll(int days) =>
      List.generate(days, (i) => i + 1).fold(0.0, (s, d) => s + debitTotal(d));
  double balance(int days) => totalCredit - totalDebitAll(days);
}

// ─── Constants ───────────────────────────────────────────────────────────────

const _kDark = Color(0xFF1A1A2E);
const _kGreen = Color.fromARGB(255, 4, 76, 8);
const _kGreenDk = Color.fromARGB(255, 2, 40, 5);
const _kRed = Color(0xFFC62828);
const _kRedDk = Color(0xFFB71C1C);
const _kGreenBg = Color(0xFFE8F5E9);
const _kRedBg = Color(0xFFFFEBEE);
const _kHeaderBg = Color(0xFFEEEEEE);
const _kSubHdrBg = Color(0xFFF5F5F5);
const _kBorderC = Color(0xFF9E9E9E);

const double _dayW = 52;
const double _crW = 100;
const double _drW = 100;
const double _balW = 100;
const double _rowH = 40.0;
const double _hdrH = 36.0;

final Map<String, HostelData> _hostels = {
  'mortel4': const HostelData(
    title: 'Hi Tech',
    totalNum: 140,
    totalAmt: 5000,
    paidNum: 86,
    paidAmt: 3200,
  ),
  'mortel5': const HostelData(
    title: 'Hi Tech 1',
    totalNum: 200,
    totalAmt: 8000,
    paidNum: 120,
    paidAmt: 4800,
  ),
  'sunrise': const HostelData(
    title: 'Hi Tech 2',
    totalNum: 80,
    totalAmt: 3200,
    paidNum: 50,
    paidAmt: 2000,
  ),
  'green': const HostelData(
    title: 'Hi Tech 3',
    totalNum: 60,
    totalAmt: 2400,
    paidNum: 40,
    paidAmt: 1600,
  ),
};

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

// ─── Main Screen ─────────────────────────────────────────────────────────────

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  String _selectedHostel = 'mortel4';
  int _curYear = DateTime.now().year;
  int _curMonth = DateTime.now().month - 1;

  // Single ledger row for the entire month (one row per month, indexed by day)
  final LedgerRow _ledger = LedgerRow();

  HostelData get _hostel => _hostels[_selectedHostel]!;
  int get _days => _daysInMonth(_curYear, _curMonth);

  void _shiftMonth(int dir) {
    setState(() {
      _curMonth += dir;
      if (_curMonth > 11) {
        _curMonth = 0;
        _curYear++;
      }
      if (_curMonth < 0) {
        _curMonth = 11;
        _curYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _HostelDropdown(
              value: _selectedHostel,
              hostels: _hostels,
              onChanged: (v) => setState(() => _selectedHostel = v!),
            ),
            const SizedBox(height: 12),
            _SummaryCard(hostel: _hostel),
            const SizedBox(height: 12),
            _LedgerCard(
              ledger: _ledger,
              year: _curYear,
              month: _curMonth,
              days: _days,
              onPrevMonth: () => _shiftMonth(-1),
              onNextMonth: () => _shiftMonth(1),
              onChanged: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hostel Dropdown ──────────────────────────────────────────────────────────

class _HostelDropdown extends StatelessWidget {
  final String value;
  final Map<String, HostelData> hostels;
  final ValueChanged<String?> onChanged;
  const _HostelDropdown({
    required this.value,
    required this.hostels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: hostels.entries
              .map(
                (e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value.title)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final HostelData hostel;
  const _SummaryCard({required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              hostel.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    'TOTAL',
                    hostel.totalNum,
                    hostel.totalAmt,
                    _kDark,
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black26),
                Expanded(
                  child: _SummaryItem(
                    'PAID',
                    hostel.paidNum,
                    hostel.paidAmt,
                    _kGreen,
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black26),
                Expanded(
                  child: _SummaryItem(
                    'BALANCE',
                    hostel.balanceNum,
                    hostel.balanceAmt,
                    _kRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int num, amt;
  final Color color;
  const _SummaryItem(this.label, this.num, this.amt, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$num',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '₹$amt',
            style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

// ─── Ledger Card ─────────────────────────────────────────────────────────────

class _LedgerCard extends StatelessWidget {
  final LedgerRow ledger;
  final int year, month, days;
  final VoidCallback onPrevMonth, onNextMonth, onChanged;

  const _LedgerCard({
    required this.ledger,
    required this.year,
    required this.month,
    required this.days,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // month nav header
          Container(
            decoration: const BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: onPrevMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  'Ledger ${_months[month]} $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: onNextMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(
              'Tap Debit cell to add entries with description',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _LedgerGrid(
              ledger: ledger,
              days: days,
              onChanged: onChanged,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ledger Grid (Column-wise: Day | Credit | Debit | Balance) ────────────────

class _LedgerGrid extends StatelessWidget {
  final LedgerRow ledger;
  final int days;
  final VoidCallback onChanged;
  final BuildContext context;

  const _LedgerGrid({
    required this.ledger,
    required this.days,
    required this.onChanged,
    required this.context,
  });

  static const BorderSide _b = BorderSide(color: _kBorderC, width: 0.8);

  @override
  Widget build(BuildContext ctx) {
    // Calculate totals
    double totalCredit = 0;
    double totalDebit = 0;
    for (int d = 1; d <= days; d++) {
      totalCredit += ledger.credit[d] ?? 0;
      totalDebit += ledger.debitTotal(d);
    }
    final grandBalance = totalCredit - totalDebit;

    return Column(
      children: [
        // ── Header row
        _buildHeaderRow(),

        // ── Day rows
        for (int d = 1; d <= days; d++) _buildDayRow(ctx, d),

        // ── Totals footer
        _buildTotalsRow(totalCredit, totalDebit, grandBalance),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        _hdrCell('Day', _dayW),
        _hdrCell('Credit', _crW, textColor: _kGreenDk),
        _hdrCell('Debit', _drW, textColor: _kRedDk),
        _hdrCell('Balance', _balW),
      ],
    );
  }

  Widget _buildDayRow(BuildContext ctx, int day) {
    final cr = ledger.credit[day];
    final dr = ledger.debitTotal(day);
    final bal = (cr ?? 0) - dr;
    final hasDebit = (ledger.debitEntries[day] ?? []).isNotEmpty;

    return Row(
      children: [
        // Day label
        _staticCell(
          'Day $day',
          _dayW,
          bg: _kSubHdrBg,
          bold: true,
          fontSize: 12,
        ),

        // Credit — editable inline
        _CreditCell(
          width: _crW,
          height: _rowH,
          value: cr,
          onChanged: (v) {
            ledger.credit[day] = v;
            onChanged();
          },
        ),

        // Debit — tap to open modal
        GestureDetector(
          onTap: () => _openDebitModal(ctx, day),
          child: Container(
            width: _drW,
            height: _rowH,
            decoration: BoxDecoration(
              color: hasDebit ? _kRedBg : Colors.white,
              border: const Border(
                right: BorderSide(color: _kBorderC, width: 0.8),
                bottom: BorderSide(color: _kBorderC, width: 0.8),
              ),
            ),
            alignment: Alignment.center,
            child: hasDebit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${dr.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _kRedDk,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.edit, size: 10, color: _kRedDk),
                    ],
                  )
                : const Text(
                    'Tap +',
                    style: TextStyle(fontSize: 11, color: Colors.black38),
                  ),
          ),
        ),

        // Balance
        Container(
          width: _balW,
          height: _rowH,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _kBorderC, width: 0.8)),
          ),
          alignment: Alignment.center,
          child: (cr != null || hasDebit)
              ? Text(
                  '₹${bal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: bal >= 0
                        ? const Color.fromARGB(255, 0, 150, 13)
                        : _kRedDk,
                  ),
                )
              : const Text(
                  '—',
                  style: TextStyle(fontSize: 12, color: Colors.black26),
                ),
        ),
      ],
    );
  }

  Widget _buildTotalsRow(double totalCr, double totalDr, double grandBal) {
    return Row(
      children: [
        Container(
          width: _dayW,
          height: _rowH,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            color: Colors.yellow,
            border: Border(right: _b, top: _b),
          ),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Total',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _totalValueCell(totalCr, const Color.fromARGB(255, 7, 52, 186), _crW),
        _totalValueCell(totalDr, _kRedDk, _drW),
        Container(
          width: _balW,
          height: _rowH,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            border: Border(top: _b),
          ),
          alignment: Alignment.center,
          child: Text(
            '₹${grandBal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: grandBal >= 0
                  ? const Color.fromARGB(255, 0, 172, 14)
                  : _kRedDk,
            ),
          ),
        ),
      ],
    );
  }

  Widget _hdrCell(String text, double width, {Color? textColor}) {
    return Container(
      width: width,
      height: _hdrH,
      decoration: const BoxDecoration(
        color: _kHeaderBg,
        border: Border(
          right: BorderSide(color: _kBorderC, width: 0.8),
          bottom: BorderSide(color: _kBorderC, width: 0.8),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _staticCell(
    String text,
    double width, {
    Color bg = Colors.white,
    bool bold = false,
    double fontSize = 12,
  }) {
    return Container(
      width: width,
      height: _rowH,
      decoration: BoxDecoration(
        color: bg,
        border: const Border(
          right: BorderSide(color: _kBorderC, width: 0.8),
          bottom: BorderSide(color: _kBorderC, width: 0.8),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _totalValueCell(double val, Color color, double width) {
    return Container(
      width: width,
      height: _rowH,
      decoration: const BoxDecoration(
        color: Colors.yellow,
        border: Border(right: _b, top: _b),
      ),
      alignment: Alignment.center,
      child: Text(
        val > 0 ? '₹${val.toStringAsFixed(0)}' : '—',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _openDebitModal(BuildContext ctx, int day) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebitModal(
        day: day,
        entries: List<DebitEntry>.from(
          (ledger.debitEntries[day] ?? []).map(
            (e) => DebitEntry(description: e.description, amount: e.amount),
          ),
        ),
        onSave: (entries) {
          ledger.debitEntries[day] = entries;
          onChanged();
        },
      ),
    );
  }
}

// ─── Credit Editable Cell ─────────────────────────────────────────────────────

class _CreditCell extends StatefulWidget {
  final double? value;
  final double width, height;
  final ValueChanged<double> onChanged;

  const _CreditCell({
    required this.value,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  State<_CreditCell> createState() => _CreditCellState();
}

class _CreditCellState extends State<_CreditCell> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value != null ? widget.value!.toStringAsFixed(0) : '',
    );
    _focus = FocusNode()
      ..addListener(() {
        setState(() => _hasFocus = _focus.hasFocus);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _hasFocus ? Colors.white : Colors.white,
        border: const Border(
          right: BorderSide(color: _kBorderC, width: 0.8),
          bottom: BorderSide(color: _kBorderC, width: 0.8),
        ),
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 34, 86, 255),
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          hintText: '—',
          hintStyle: TextStyle(fontSize: 12, color: Colors.black26),
        ),
        onChanged: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) widget.onChanged(parsed);
        },
      ),
    );
  }
}

// ─── Debit Modal ──────────────────────────────────────────────────────────────

class _DebitModal extends StatefulWidget {
  final int day;
  final List<DebitEntry> entries;
  final void Function(List<DebitEntry>) onSave;

  const _DebitModal({
    required this.day,
    required this.entries,
    required this.onSave,
  });

  @override
  State<_DebitModal> createState() => _DebitModalState();
}

class _DebitModalState extends State<_DebitModal> {
  late List<DebitEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.entries);
    // Always start with at least one empty row if no entries
    if (_entries.isEmpty) {
      _entries.add(DebitEntry(description: '', amount: 0));
    }
  }

  double get _total => _entries.fold(0, (s, e) => s + e.amount);

  void _addEntry() {
    setState(() {
      _entries.add(DebitEntry(description: '', amount: 0));
    });
  }

  void _removeEntry(int i) {
    setState(() => _entries.removeAt(i));
  }

  void _save() {
    // Filter out empty rows
    final valid = _entries
        .where((e) => e.description.trim().isNotEmpty || e.amount > 0)
        .toList();
    widget.onSave(valid);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kRedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${widget.day}',
                    style: const TextStyle(
                      color: _kRedDk,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Debit Entries',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kRedDk,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: ₹${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 90,
                  child: Text(
                    'Amount (₹)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),

          // Entry list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              itemBuilder: (_, i) => _EntryRow(
                entry: _entries[i],
                index: i,
                onDelete: _entries.length > 1 ? () => _removeEntry(i) : null,
                onChanged: () => setState(() {}),
              ),
            ),
          ),

          // Add row button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextButton.icon(
              onPressed: _addEntry,
              icon: const Icon(
                Icons.add_circle_outline,
                size: 16,
                color: _kDark,
              ),
              label: const Text(
                'Add another entry',
                style: TextStyle(color: _kDark, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: _kSubHdrBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Save / Cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.black26),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save  ₹${_total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Entry Row inside Modal ───────────────────────────────────────────────────

class _EntryRow extends StatefulWidget {
  final DebitEntry entry;
  final int index;
  final VoidCallback? onDelete;
  final VoidCallback onChanged;

  const _EntryRow({
    required this.entry,
    required this.index,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _amtCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.entry.description);
    _amtCtrl = TextEditingController(
      text: widget.entry.amount > 0
          ? widget.entry.amount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Description field
          Expanded(
            flex: 3,
            child: TextField(
              controller: _descCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Rent, Food…',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorderC),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorderC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kDark, width: 1.5),
                ),
              ),
              onChanged: (v) {
                widget.entry.description = v;
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Amount field
          SizedBox(
            width: 90,
            child: TextField(
              controller: _amtCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _kRedDk,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                prefixText: '₹',
                prefixStyle: const TextStyle(color: _kRedDk, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorderC),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorderC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kRedDk, width: 1.5),
                ),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v) ?? 0;
                widget.entry.amount = parsed;
                widget.onChanged();
              },
            ),
          ),
          // Delete button
          SizedBox(
            width: 36,
            child: widget.onDelete != null
                ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
