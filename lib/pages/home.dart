// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:test_tktw/constants/assets.dart';
import '../data/datasource/remote_datasource.dart';
import '../data/model/customer.dart';
import '../data/model/gift_summary.dart';
import '../data/model/confirm_request.dart';
import 'home/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(remoteDatasource: RemoteDatasource())
        ..add(LoadAllCustomersEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is GiftSummaryLoaded) {
              _showGiftSummaryDialog(context, state.giftSummary);
            } else if (state is AllCustomersWithGiftSummaryLoaded) {
              _showGiftSummaryDialog(context, state.giftSummary);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeState state) {
    List<String> customers = [];
    String? selectedCustomer;

    if (state is CustomerListLoaded) {
      customers = state.customers.map((c) => c.name).toList();
      selectedCustomer = state.selectedCustomer?.name;
    } else if (state is CustomerDetailLoaded) {
      customers = state.customers.map((c) => c.name).toList();
      selectedCustomer = state.selectedCustomer.name;
    } else if (state is GiftSummaryLoaded) {
      customers = state.customers.map((c) => c.name).toList();
      selectedCustomer = state.selectedCustomer.name;
    } else if (state is AllCustomersLoaded) {
      customers = state.customerList.map((c) => c.name).toList();
      selectedCustomer = 'Semua Toko';
    } else if (state is AllCustomersWithGiftSummaryLoaded) {
      customers = state.customerList.map((c) => c.name).toList();
      selectedCustomer = 'Semua Toko';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 0, 151, 134)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Icon(Icons.store_outlined,
                          size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Semua Toko',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  value: selectedCustomer,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Semua Toko',
                      child: Row(
                        children: [
                          Icon(Icons.store_mall_directory_outlined,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Semua Toko',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    ...customers
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Row(
                                children: [
                                  Icon(Icons.store_outlined,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ))
                        ,
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      if (value == 'Semua Toko') {
                        context.read<HomeBloc>().add(LoadAllCustomersEvent());
                      } else {
                        final custID = _getCustomerIDByName(state, value);
                        if (custID != null) {
                          context
                              .read<HomeBloc>()
                              .add(SelectCustomerEvent(custID));
                        }
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(LoadGiftSummaryEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Icon(Icons.card_giftcard, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Total Hadiah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator(
        color: Color(0xFF00897B),
      ));
    }

    if (state is AllCustomersLoaded ||
        state is AllCustomersWithGiftSummaryLoaded) {
      if (state is AllCustomersLoaded) {
        return _buildAllCustomersList(context, state);
      } else if (state is AllCustomersWithGiftSummaryLoaded) {
        
        final allCustomersState = AllCustomersLoaded(
          customerList: state.customerList,
          allCustomers: state.allCustomers,
        );
        return _buildAllCustomersList(context, allCustomersState);
      }
    }

    if (state is CustomerDetailLoaded || state is GiftSummaryLoaded) {
      if (state is CustomerDetailLoaded) {
        return _buildCustomerDetail(context, state);
      } else if (state is GiftSummaryLoaded) {
        final customerDetailState = CustomerDetailLoaded(
          customers: state.customers,
          selectedCustomer: state.selectedCustomer,
          customerDetail: state.customerDetail,
        );
        return _buildCustomerDetail(context, customerDetailState);
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Pilih toko untuk melihat detail',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetail(
      BuildContext context, CustomerDetailLoaded state) {
    final customer = state.customerDetail;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Toko',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomerCard(context, customer),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCustomersList(
      BuildContext context, AllCustomersLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua Toko & Hadiah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (state.allCustomers.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.allCustomers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final customer = state.allCustomers[index];
                  return _buildCustomerCard(context, customer);
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada data toko',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    String status;
    bool? allReceived;
    bool? anyFailed;

    if (customer.gifts == null || customer.gifts!.isEmpty) {
      status = 'Belum Diberikan';
    } else {
      allReceived = customer.gifts!.every((gift) => gift.received);
      anyFailed = customer.gifts!.any(
        (gift) =>
            !gift.received &&
            gift.failedReason != null &&
            gift.failedReason!.isNotEmpty,
      );

      if (allReceived) {
        status = 'Sudah Diterima';
      } else if (anyFailed) {
        status = 'Gagal Diterima';
      } else {
        status = 'Belum Diberikan';
      }
    }

    return GestureDetector(
      onTap: () {
        if (allReceived == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Toko sudah menerima hadiah!'),
              backgroundColor: Colors.yellow,
            ),
          );
        } else {
          _showConfirmationDialog(context, customer);
        }
      },
      child: Column(
        children: [
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF00897B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (customer.address != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customer.address!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (customer.phoneNo != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customer.phoneNo!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            transform: Matrix4.translationValues(0, -20, 0),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color: Color(0xFF00897B),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daftar Hadiah (${customer.gifts?.length ?? 0})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00897B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (customer.gifts != null && customer.gifts!.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customer.gifts!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final gift = customer.gifts![index];
                      return _buildCompactGiftCard(gift);
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tidak ada hadiah',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGiftCard(Gift gift) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF26A69A), // Lighter Teal
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.iconGiftColor,
              height: 30,
            ),
            const SizedBox(width: 16),
            Text(
              gift.ttOTTPNo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getCustomerIDByName(HomeState state, String name) {
    if (state is CustomerListLoaded) {
      return state.customers.firstWhere((c) => c.name == name).custID;
    } else if (state is CustomerDetailLoaded) {
      return state.customers.firstWhere((c) => c.name == name).custID;
    } else if (state is GiftSummaryLoaded) {
      return state.customers.firstWhere((c) => c.name == name).custID;
    } else if (state is AllCustomersLoaded) {
      return state.customerList.firstWhere((c) => c.name == name).custID;
    } else if (state is AllCustomersWithGiftSummaryLoaded) {
      return state.customerList.firstWhere((c) => c.name == name).custID;
    }
    return null;
  }

  void _showGiftSummaryDialog(BuildContext context, GiftSummary summary) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            Assets.iconGiftColor,
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Total Hadiah',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 151, 134),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              // Return to appropriate state after closing dialog
                              // final currentState =
                              //     context.read<HomeBloc>().state;
                              // if (currentState
                              //     is AllCustomersWithGiftSummaryLoaded) {
                              //   context
                              //       .read<HomeBloc>()
                              //       .add(LoadAllCustomersEvent());
                              // }
                            },
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Divider(color: Colors.yellow, thickness: 1.5),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: summary.itemsList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = summary.itemsList[index];
                    return _buildSummaryItem(item);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Divider(color: Colors.yellow, thickness: 1.5),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${summary.total} Hadiah',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Handle dialog dismissal (when user taps outside or presses back)
      
      final currentState = context.read<HomeBloc>().state;
      if (currentState is AllCustomersWithGiftSummaryLoaded) {
        context.read<HomeBloc>().add(LoadAllCustomersEvent());
      }
    });
  }

  Widget _buildSummaryItem(GiftSummaryItem item) {
    IconData icon;
    Color iconColor;

    if (item.name.contains('Emas')) {
      icon = Icons.star;
      iconColor = const Color(0xFFFFD700);
    } else {
      icon = Icons.confirmation_number;
      iconColor = const Color(0xFFFF6B35);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.qty} ${item.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Sudah Terima TTH',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Illustration (you can replace with actual illustration)
              SizedBox(
                width: 120,
                height: 120,
                child: SvgPicture.asset(
                  Assets.ilQuestion,
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),
              // Question text
              const Text(
                'Yakin ingin menyimpan sudah terima TTH?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _showRejectReasonDialog(context, customer);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00897B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'TIDAK',
                        style: TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _confirmReceived(context, customer);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'YA, SUDAH TERIMA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectReasonDialog(BuildContext context, Customer customer) {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Gagal Terima TTH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00897B)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Pilih Alasan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      value: selectedReason,
                      items: [
                        'Toko Tutup',
                        'Pemilik Toko Tidak Ada',
                      ]
                          .map((reason) => DropdownMenuItem<String>(
                                value: reason,
                                child: Text(
                                  reason,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00897B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            color: Color(0xFF00897B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedReason != null
                            ? () {
                                Navigator.of(dialogContext).pop();
                                _confirmRejected(
                                    context, customer, selectedReason ?? '');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'SIMPAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReceived(BuildContext context, Customer customer) async {
    try {
      final remoteDatasource = RemoteDatasource();
      final confirmRequest = ConfirmRequest(action: 'accept', reason: '');

      final response = await remoteDatasource.confirmCustomer(
          customer.custID, confirmRequest);

      if (response.success) {
        // Refresh the data
        context.read<HomeBloc>().add(LoadAllCustomersEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengkonfirmasi penerimaan TTH'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal mengkonfirmasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmRejected(
      BuildContext context, Customer customer, String reason
    ) async {
    try {
      final remoteDatasource = RemoteDatasource();
      final confirmRequest = ConfirmRequest(action: 'reject', reason: reason);

      final response = await remoteDatasource.confirmCustomer(customer.custID, confirmRequest);

      if (response.success) {
        // Refresh the data
        context.read<HomeBloc>().add(LoadAllCustomersEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menolak penerimaan TTH'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal menolak'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
