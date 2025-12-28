import 'package:fl_chart/fl_chart.dart';

import '../../../../core/app_export.dart';

class ChartSectionWidget extends StatefulWidget {
  const ChartSectionWidget({super.key});

  @override
  State<ChartSectionWidget> createState() => _ChartSectionWidgetState();
}

class _ChartSectionWidgetState extends State<ChartSectionWidget> {
  int selectedChartIndex = 0;

  final List<Map<String, dynamic>> chartData = [
    {
      'title': 'Fraud Trends',
      'type': 'line',
      'data': [
        {'x': 0, 'y': 12},
        {'x': 1, 'y': 8},
        {'x': 2, 'y': 15},
        {'x': 3, 'y': 6},
        {'x': 4, 'y': 20},
        {'x': 5, 'y': 14},
        {'x': 6, 'y': 9},
      ],
    },
    {
      'title': 'Verification Stats',
      'type': 'bar',
      'data': [
        {'x': 0, 'y': 45},
        {'x': 1, 'y': 38},
        {'x': 2, 'y': 52},
        {'x': 3, 'y': 41},
        {'x': 4, 'y': 48},
        {'x': 5, 'y': 55},
        {'x': 6, 'y': 43},
      ],
    },
    {
      'title': 'User Engagement',
      'type': 'pie',
      'data': [
        {'label': 'Active', 'value': 65, 'color': AppTheme.successAccent},
        {'label': 'Inactive', 'value': 25, 'color': AppTheme.warningColor},
        {'label': 'Suspended', 'value': 10, 'color': AppTheme.errorColor},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Overview',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.analytics,
                color: AppTheme.primaryBlue,
                size: 5.w,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                chartData.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedChartIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 2.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: selectedChartIndex == index
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedChartIndex == index
                            ? AppTheme.primaryBlue
                            : AppTheme.neutralBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      chartData[index]['title'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: selectedChartIndex == index
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            height: 25.h,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final currentChart = chartData[selectedChartIndex];
    final chartType = currentChart['type'] as String;

    switch (chartType) {
      case 'line':
        return _buildLineChart(currentChart['data'] as List);
      case 'bar':
        return _buildBarChart(currentChart['data'] as List);
      case 'pie':
        return _buildPieChart(currentChart['data'] as List);
      default:
        return Container();
    }
  }

  Widget _buildLineChart(List data) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: (data as List<Map<String, dynamic>>)
                .map((point) => FlSpot(
                      (point['x'] as int).toDouble(),
                      (point['y'] as int).toDouble(),
                    ))
                .toList(),
            isCurved: true,
            color: AppTheme.primaryBlue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List data) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: (data as List<Map<String, dynamic>>)
            .map((point) => BarChartGroupData(
                  x: point['x'] as int,
                  barRods: [
                    BarChartRodData(
                      toY: (point['y'] as int).toDouble(),
                      color: AppTheme.successAccent,
                      width: 4.w,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPieChart(List data) {
    return PieChart(
      PieChartData(
        sections: (data as List<Map<String, dynamic>>)
            .map((point) => PieChartSectionData(
                  value: (point['value'] as int).toDouble(),
                  color: point['color'] as Color,
                  title: '${point['value']}%',
                  radius: 8.w,
                  titleStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ))
            .toList(),
        centerSpaceRadius: 6.w,
        sectionsSpace: 2,
      ),
    );
  }
}
