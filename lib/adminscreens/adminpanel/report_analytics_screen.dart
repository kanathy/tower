import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportAnalyticsScreen extends StatelessWidget {
  const ReportAnalyticsScreen({super.key});

  // Demo data - In production, fetch from Firebase
  final int totalIncidents = 23;
  final int fallCases = 12;
  final int healthAlerts = 8;
  final int criticalCases = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Richer Light Purple
            Color(0xFFD1C4E9), // Deeper Lavender
            Color(0xFFB3E5FC), // Saturated Light Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4C0B58), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Safety Analytics",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4C0B58),
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Row
              Row(
                children: [
                  _buildQuickStat("Total", totalIncidents.toString(), Icons.warning_amber_rounded, const Color(0xFF3498DB)),
                  const SizedBox(width: 12),
                  _buildQuickStat("Falls", fallCases.toString(), Icons.accessibility_new_rounded, const Color(0xFFE74C3C)),
                  const SizedBox(width: 12),
                  _buildQuickStat("Alerts", healthAlerts.toString(), Icons.monitor_heart_rounded, const Color(0xFFF39C12)),
                  const SizedBox(width: 12),
                  _buildQuickStat("Critical", criticalCases.toString(), Icons.error_rounded, const Color(0xFF9B59B6)),
                ],
              ),
              
              const SizedBox(height: 28),

              // Fall Detection Summary Section
              _buildSectionHeader("Fall Detection Summary", Icons.accessibility_new_rounded),
              const SizedBox(height: 12),
              _buildFallDetectionCard(),

              const SizedBox(height: 24),

              // Climate & Weather Section
              _buildSectionHeader("Climate Conditions", Icons.cloud_rounded),
              const SizedBox(height: 12),
              _buildClimateCard(),

              const SizedBox(height: 24),

              // Safety Equipment Status
              _buildSectionHeader("Safety Equipment Status", Icons.shield_rounded),
              const SizedBox(height: 12),
              _buildSafetyEquipmentCard(),

              const SizedBox(height: 24),

              // Accident Distribution Chart
              _buildSectionHeader("Incident Distribution", Icons.pie_chart_rounded),
              const SizedBox(height: 12),
              _buildPieChartCard(),

              const SizedBox(height: 24),

              // Monthly Trend
              _buildSectionHeader("Monthly Trend", Icons.trending_up_rounded),
              const SizedBox(height: 12),
              _buildTrendCard(),

              const SizedBox(height: 24),

              // Accident Causes
              _buildSectionHeader("Accident Causes", Icons.bar_chart_rounded),
              const SizedBox(height: 12),
              _buildCausesChart(),

              const SizedBox(height: 24),

              // AI Insights
              _buildSectionHeader("AI Safety Insights", Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
              _buildInsightsCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4C0B58), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildFallDetectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person_off_rounded, color: Colors.red.shade700, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "12 Falls Detected",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      "This Month",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.red.shade700),
                    Text(
                      " 15%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFallStat("Tower 001", "5", Colors.red),
              const SizedBox(width: 12),
              _buildFallStat("Tower 042", "4", Colors.orange),
              const SizedBox(width: 12),
              _buildFallStat("Tower 108", "3", Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Most falls occurred during afternoon shifts (2-5 PM). Consider fatigue monitoring.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallStat(String tower, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              tower,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildClimateItem(Icons.thermostat_rounded, "32°C", "Temperature", Colors.orange),
              _buildClimateItem(Icons.water_drop_rounded, "78%", "Humidity", Colors.blue),
              _buildClimateItem(Icons.air_rounded, "18 km/h", "Wind", Colors.teal),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "High Temperature Alert",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      Text(
                        "Ensure workers take regular hydration breaks",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildWeatherIssue("Heat Stress Cases", "4", Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildWeatherIssue("Wind Delays", "2", Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildWeatherIssue("Rain Stops", "1", Colors.indigo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClimateItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIssue(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyEquipmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEquipmentRow("Harness", 95, Colors.green),
          const SizedBox(height: 12),
          _buildEquipmentRow("Helmet", 100, Colors.green),
          const SizedBox(height: 12),
          _buildEquipmentRow("Safety Boots", 88, Colors.orange),
          const SizedBox(height: 12),
          _buildEquipmentRow("Gloves", 72, Colors.red),
        ],
      ),
    );
  }

  Widget _buildEquipmentRow(String name, int percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "$percent%",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(value: 12, title: 'Fall\n52%', color: const Color(0xFFE74C3C), radius: 50, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              PieChartSectionData(value: 8, title: 'Health\n35%', color: const Color(0xFFF39C12), radius: 50, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              PieChartSectionData(value: 3, title: 'Other\n13%', color: const Color(0xFF3498DB), radius: 50, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
                    if (value.toInt() < months.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(months[value.toInt()], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      );
                    }
                    return const Text("");
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [FlSpot(0, 3), FlSpot(1, 6), FlSpot(2, 4), FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 3)],
                isCurved: true,
                barWidth: 3,
                color: const Color(0xFF4C0B58),
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: const Color(0xFF4C0B58).withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCausesChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: [
              _bar(0, 7, const Color(0xFFE74C3C)),
              _bar(1, 5, const Color(0xFFF39C12)),
              _bar(2, 4, const Color(0xFF3498DB)),
              _bar(3, 3, const Color(0xFF27AE60)),
            ],
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const labels = ["No Gear", "Fatigue", "Weather", "Health"];
                    if (value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      );
                    }
                    return const Text("");
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 24,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4C0B58).withOpacity(0.1), const Color(0xFF8E319B).withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4C0B58).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C0B58).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4C0B58), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "AI-Powered Recommendations",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4C0B58),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem("⚠️", "High fall rate at Tower 001 - Schedule safety inspection"),
          _buildInsightItem("🌡️", "Heat stress incidents up 40% - Implement mandatory breaks"),
          _buildInsightItem("🔧", "72% glove compliance detected - Reinforce equipment policy"),
          _buildInsightItem("📊", "Peak accident hours: 2-5 PM - Consider shift adjustments"),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3436),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}