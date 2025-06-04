import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> {
  final TextEditingController _amountController = TextEditingController();

  // Exchange rates against USD (dummy data - in real app, you'd fetch from API)
  // This map stores how much 1 USD is worth in other currencies.
  final Map<String, double> exchangeRates = {
    'USD': 1.0, // Base currency for our calculations
    'IDR': 16290.0,
    'EUR': 0.88,
    'GBP': 0.74,
    'JPY': 142.8,
  };

  String _fromCurrency = 'USD'; // Default "from" currency
  String _toCurrency = 'IDR'; // Default "to" currency
  double _convertedAmount = 0.0;

  // F1 Championship dummy data
  final List<Map<String, dynamic>> championships = [
    {
      'name': 'Monaco Grand Prix',
      'location': 'Circuit de Monaco, Monte Carlo',
      'date': 'May 26, 2024',
      'price': 850.0,
      'image': Icons.sports_motorsports,
    },
    {
      'name': 'Silverstone Grand Prix',
      'location': 'Silverstone Circuit, United Kingdom',
      'date': 'July 7, 2024',
      'price': 650.0,
      'image': Icons.sports_motorsports,
    },
  ];

  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount == 0.0) {
      setState(() {
        _convertedAmount = 0.0;
      });
      return;
    }

    // Convert "from" currency to USD
    double amountInUsd;
    if (_fromCurrency == 'USD') {
      amountInUsd = amount;
    } else {
      // If 1 USD = X of _fromCurrency, then 1 of _fromCurrency = 1/X USD
      amountInUsd = amount / exchangeRates[_fromCurrency]!;
    }

    // Convert USD to "to" currency
    setState(() {
      _convertedAmount = amountInUsd * exchangeRates[_toCurrency]!;
    });
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'USD':
        return '\$';
      default:
        return '';
    }
  }

  String _formatConvertedAmount(String currency, double amount) {
    switch (currency) {
      case 'IDR':
        return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
      case 'JPY':
        return amount.toStringAsFixed(0);
      case 'EUR':
      case 'GBP':
      case 'USD':
        return amount.toStringAsFixed(2);
      default:
        return amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F1 Tickets',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[700]!, Colors.red[50]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Championships Section
              const Text(
                'Available Championships',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Championship Cards
              ...championships.map(
                (championship) => Card(
                  elevation: 8,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey[50]!],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              championship['image'],
                              size: 40,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    championship['name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    championship['location'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  championship['date'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${championship['price'].toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Currency Converter Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.blue[50]!],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.currency_exchange,
                            size: 32,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Currency Converter',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Currency Selection Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _fromCurrency,
                              decoration: InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  exchangeRates.keys.map((String currency) {
                                    return DropdownMenuItem<String>(
                                      value: currency,
                                      child: Text(currency),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _fromCurrency = newValue!;
                                  _convertCurrency();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.arrow_right_alt,
                            size: 30,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _toCurrency,
                              decoration: InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  exchangeRates.keys.map((String currency) {
                                    return DropdownMenuItem<String>(
                                      value: currency,
                                      child: Text(currency),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _toCurrency = newValue!;
                                  _convertCurrency();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Amount Input
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,16}(\.\d{0,3})?$'),
                          ), // Mengizinkan hingga 16 digit sebelum koma, atau koma dengan 3 digit setelahnya
                          LengthLimitingTextInputFormatter(
                            20,
                          ), // Sesuaikan batas panjang total yang masuk akal
                        ],
                        decoration: InputDecoration(
                          labelText:
                              'Amount (${_getCurrencySymbol(_fromCurrency)})',
                          prefixIcon: Icon(Icons.money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          hintText: 'Enter amount (max 16 digits)',
                        ),
                        onChanged: (value) {
                          _convertCurrency();
                        },
                      ),
                      const SizedBox(height: 20),

                      // Converted Value Display
                      if (_amountController.text.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Converted Value:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _toCurrency,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_getCurrencySymbol(_toCurrency)}${_formatConvertedAmount(_toCurrency, _convertedAmount)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
