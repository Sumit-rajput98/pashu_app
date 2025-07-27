import 'package:flutter/material.dart';

class ProjectFAQWidget extends StatefulWidget {
  const ProjectFAQWidget({super.key});

  @override
  State<ProjectFAQWidget> createState() => _ProjectFAQWidgetState();
}

class _ProjectFAQWidgetState extends State<ProjectFAQWidget> {
  final List<Map<String, String>> faqs = [
    {
      "question": "What is the Pashuparivar Investment Scheme?",
      "answer":
      "Pashuparivar Investment Scheme is an initiative where individuals can invest in livestock-based businesses, through the Pashuparivar platform and earn returns based on profit-sharing or fixed models.",
    },
    {
      "question": "How does the investment model work?",
      "answer":
      "You invest a specific amount, which will be used for purchasing and maintaining dairy animals. Our partnered farmers take care of daily operations, and profits from milk sales or animal trade are shared as per agreed terms.",
    },
    {
      "question": "Is my investment safe?",
      "answer":
      "All investments are made transparently with proper documentation. Livestock is insured, and the farm operations are monitored by our team. However, like any investment, this also carries minimal risks.",
    },
    {
      "question": "How will I earn returns?",
      "answer":
      "Returns are either fixed (monthly/quarterly) or profit-based depending on the plan you choose. Details are provided in the agreement for each plan.",
    },
    {
      "question": "When will I get my returns?",
      "answer":
      "Returns are disbursed as per the payment cycle chosen — monthly, quarterly, or annually. The complete details will be shared at the time of agreement.",
    },
    {
      "question": "Can I visit the farm?",
      "answer":
      "Yes, investors can visit partner farms after scheduling an appointment with our support team.",
    },
    {
      "question": "Is there any agreement?",
      "answer":
      "Yes, we provide a legally binding MoU (Memorandum of Understanding) outlining your investment details, responsibilities, risk factors, and return timelines.",
    },
    {
      "question": "How can I withdraw my investment?",
      "answer":
      "Most projects have a minimum lock-in period. After that, you can exit or choose to reinvest. Early withdrawal may be subject to charges or forfeiture of returns.",
    },
  ];

  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    expanded = List.generate(faqs.length, (index) => false);
  }

  void toggle(int index) {
    setState(() {
      expanded[index] = !expanded[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDEF0C2), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 8),
              Text(
                "❓ Frequently Asked Questions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E4A59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(faqs.length, (index) {
            return Column(
              children: [
                InkWell(
                  onTap: () => toggle(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            faqs[index]['question']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(expanded[index]
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
                if (expanded[index])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      faqs[index]['answer']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                const Divider(thickness: 0.5),
              ],
            );
          }),
        ],
      ),
    );
  }
}
