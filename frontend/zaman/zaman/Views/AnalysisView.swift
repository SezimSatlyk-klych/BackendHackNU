//
//  AnalysisView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI
import Charts

// MARK: - Analysis View
struct AnalysisView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time Range Selector
                timeRangeSelector
                
                // Income vs Expenses Line Chart
                incomeExpensesChart
                
                // Spending Categories Pie Chart
                spendingCategoriesChart
                
                // Summary Cards
                summaryCards
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Financial Analysis")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        HStack {
            Text("Time Range")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Income vs Expenses Line Chart
    private var incomeExpensesChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Income vs Expenses")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showDatePicker = true
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.teal)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Time Period Selector
            HStack(spacing: 12) {
                Button(action: {
                    selectedTimeRange = .week
                }) {
                    TimePeriodButton(title: "Week", isSelected: selectedTimeRange == .week)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    selectedTimeRange = .month
                }) {
                    TimePeriodButton(title: "Month", isSelected: selectedTimeRange == .month)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    selectedTimeRange = .year
                }) {
                    TimePeriodButton(title: "Year", isSelected: selectedTimeRange == .year)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Chart {
                // Income Line (Teal)
                ForEach(chartData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Amount", data.income)
                    )
                    .foregroundStyle(.teal)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
                .symbolSize(60)
                
                // Expenses Line (Purple)
                ForEach(chartData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Amount", data.expenses)
                    )
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
                .symbolSize(60)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartBackground { chartProxy in
                // Add grid lines
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .overlay(
                            GridLines()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.teal)
                        .frame(width: 12, height: 12)
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(.purple)
                        .frame(width: 12, height: 12)
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Spending Categories Pie Chart
    private var spendingCategoriesChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart {
                ForEach(categoryData, id: \.category) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.3),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", data.category))
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom, alignment: .center) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(categoryData, id: \.category) { data in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            Text(data.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Summary Cards
    private var summaryCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            SummaryCard(
                title: "Total Income",
                value: "$\(Int(totalIncome))",
                icon: "arrow.up.circle.fill",
                color: .green
            )
            
            SummaryCard(
                title: "Total Expenses",
                value: "$\(Int(totalExpenses))",
                icon: "arrow.down.circle.fill",
                color: .red
            )
            
            SummaryCard(
                title: "Net Balance",
                value: "$\(Int(netBalance))",
                icon: "dollarsign.circle.fill",
                color: netBalance >= 0 ? .green : .red
            )
            
            SummaryCard(
                title: "Top Category",
                value: topCategory,
                icon: "chart.pie.fill",
                color: .blue
            )
        }
    }
    
    // MARK: - Computed Properties
    private var chartData: [ChartDataPoint] {
        // Generate realistic data points for the chart
        let calendar = Calendar.current
        let endDate = Date()
        
        let dataPoints: Int
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            dataPoints = 7
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        case .month:
            dataPoints = 5 // 5 months of data
            startDate = calendar.date(byAdding: .month, value: -5, to: endDate) ?? endDate
        case .year:
            dataPoints = 12 // 12 months of data
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        }
        
        var data: [ChartDataPoint] = []
        
        // Generate realistic financial data
        let baseIncome = 4500.0
        let baseExpenses = 3200.0
        
        for i in 0..<dataPoints {
            let date: Date
            if selectedTimeRange == .week {
                date = calendar.date(byAdding: .day, value: i, to: startDate) ?? endDate
            } else {
                date = calendar.date(byAdding: .month, value: i, to: startDate) ?? endDate
            }
            
            // Add realistic variation to the data
            let incomeVariation = Double.random(in: -500...800)
            let expenseVariation = Double.random(in: -300...600)
            
            let income = baseIncome + incomeVariation + (Double(i) * 100) // Slight upward trend
            let expenses = baseExpenses + expenseVariation + (Double(i) * 50) // Slight upward trend
            
            data.append(ChartDataPoint(date: date, income: income, expenses: expenses))
        }
        
        return data
    }
    
    private var categoryData: [CategoryData] {
        // Group transactions by type/category
        let expenseCategories = Dictionary(grouping: homeViewModel.transactionsTo) { $0.type }
        
        let colors: [Color] = [.blue, .orange, .purple, .red, .green, .cyan, .pink, .indigo]
        
        return expenseCategories.map { (category, transactions) in
            let totalAmount = transactions.reduce(0) { $0 + Double(truncating: $1.sum as NSDecimalNumber) }
            let colorIndex = abs(category.hashValue) % colors.count
            return CategoryData(category: category, amount: totalAmount, color: colors[colorIndex])
        }.sorted { $0.amount > $1.amount }
    }
    
    private var totalIncome: Double {
        homeViewModel.transactionsFrom.reduce(0) { $0 + Double(truncating: $1.sum as NSDecimalNumber) }
    }
    
    private var totalExpenses: Double {
        homeViewModel.transactionsTo.reduce(0) { $0 + Double(truncating: $1.sum as NSDecimalNumber) }
    }
    
    private var netBalance: Double {
        totalIncome - totalExpenses
    }
    
    private var topCategory: String {
        categoryData.max(by: { $0.amount < $1.amount })?.category ?? "N/A"
    }
}

// MARK: - Chart Data Models
struct ChartDataPoint {
    let date: Date
    let income: Double
    let expenses: Double
}

struct CategoryData {
    let category: String
    let amount: Double
    let color: Color
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Time Period Button
struct TimePeriodButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                LinearGradient(
                    gradient: Gradient(colors: [Color.teal, Color.cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                ) : 
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray6)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
    }
}

// MARK: - Grid Lines
struct GridLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Vertical grid lines
        for i in 0...10 {
            let x = rect.minX + (rect.width * CGFloat(i) / 10.0)
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        
        // Horizontal grid lines
        for i in 0...6 {
            let y = rect.minY + (rect.height * CGFloat(i) / 6.0)
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        return path
    }
}

// MARK: - Preview
#Preview {
    AnalysisView()
        .environmentObject(HomeViewModel())
        .environmentObject(AuthViewModel())
}
