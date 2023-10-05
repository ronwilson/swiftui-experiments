//
//  ScorecardView.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 10/1/23.
//
import SwiftUI

struct ScorecardView: View {

    let tee: Tee
    var players: [PlayerScore] = [PlayerScore]()

    init(tee: Tee) {
        self.tee = tee
#if TEST_PLAYER_SCORE
        self.players = PlayerScore.randomPlayers(tee: tee)
#endif
    }

    var body: some View {
        Self._printChanges()
        return VStack {
            ScorecardInnerView(tee: tee, players: players)
        }
        .padding(5)
        .navigationTitle("Scorecard")
        .navigationBarTitleDisplayMode(.inline)
    }


}

struct NumberText : Identifiable {
    let id: Int
    let txt: String
}

struct ScorecardInnerView: View {

    @Environment(\.colorScheme) var colorScheme

    let tee: Tee
    let players: [PlayerScore]
    let fontsize: CGFloat = CGFloat(UserDefaults.scorecardFontSize)
    let colwidth = 3
    let summarywidth = 5
    let minHeaderColWidth = 8
    let holesFront9 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let holesBack9 = [10, 11, 12, 13, 14, 15, 16, 17, 18]

    var holeTextColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var headerColumnWidth: Int {
        return max(players.reduce(0, { max($0, $1.name.count) }) + 2, minHeaderColWidth)
    }


    struct ScoreRowHeader: View {
        @Environment(\.colorScheme) var colorScheme
        var holeTextColor: Color {
            colorScheme == .dark ? .black : .white
        }
        let playernames: [String]
        let width: Int
        var body: some View {
            VStack(alignment: .leading) {
                Text("Hole".padding(toLength: width, withPad: " ", startingAt: 0))
                    .scoreBackground(type: .holes)
                    .foregroundColor(holeTextColor)
                Text("Hcp".padding(toLength: width, withPad: " ", startingAt: 0))
                    .scoreBackground(type: .label)
                Text("Strokes".padding(toLength: width, withPad: " ", startingAt: 0))
                ForEach(playernames, id: \.self) { player in
                    Text(" \(player)".padding(toLength: width-1, withPad: " ", startingAt: 0))
                }
                Text("Par".padding(toLength: width, withPad: " ", startingAt: 0))
                    .scoreBackground(type: .label)
                Text("Net".padding(toLength: width, withPad: " ", startingAt: 0))
                ForEach(playernames, id: \.self) { player in
                    Text(" \(player)".padding(toLength: width-1, withPad: " ", startingAt: 0))
                }
            }
        }
    }

    struct SummaryRowHeader: View {
        @Environment(\.colorScheme) var colorScheme
        var headerTextColor: Color {
            colorScheme == .dark ? .black : .white
        }
        let playernames: [String]
        let width: Int
        var body: some View {
            VStack(alignment: .leading) {
                Text("Summary".padding(toLength: width, withPad: " ", startingAt: 0))
                    .scoreBackground(type: .holes)
                    .foregroundColor(headerTextColor)
                Text("Par".padding(toLength: width, withPad: " ", startingAt: 0))
                    .scoreBackground(type: .label)
                ForEach(playernames, id: \.self) { player in
                    Text("\(player)".padding(toLength: width, withPad: " ", startingAt: 0))
                }
            }
        }
    }

    var body: some View {
        Self._printChanges()
        return  ScrollView(.vertical, showsIndicators:false) {
            VStack {
                // Front 9
                HStack(spacing: 0) {
                    ScoreRowHeader(playernames: players.map({ $0.name }), width: headerColumnWidth)
                    .font(.system(size: fontsize, design: .monospaced))
                    ScrollView(.horizontal, showsIndicators:false) {
                        VStack(alignment: .trailing) {
                            // Front9 Hole Row
                            ScoreGridTextRow(values: numberGridRow(holesFront9, width: colwidth))
                                .scoreBackground(type: .holes)
                                .foregroundColor(holeTextColor)
                            // Front9 Hcp Row
                            ScoreGridTextRow(values: numberGridRow(tee.handicaps(for: 0...8), width: colwidth))
                                .scoreBackground(type: .label)
                            // Front9 Strokes Empty Row
                            ScoreGridTextRow(values: ScorecardInnerView.emptyGridRow)
                            // Front9 player strokes and out row
                            ForEach(players) { player in
                                ScoreGridTextRow(values: stringGridRow(player.strokes(0...8, tee: tee), width: colwidth))
                            }
                            // Front9 Pars Row
                            ScoreGridTextRow(values: numberGridRow(tee.pars(for: 0...8), width: colwidth))
                                .scoreBackground(type: .label)
                            // Front9 Score Empty Row
                            ScoreGridTextRow(values: ScorecardInnerView.emptyGridRow)
                            // match/score
                            ForEach(players) { player in
                                ScoreGridTextRow(values: numberGridRow(player.scores(0...8, tee:tee), width: colwidth))
                            }
                        }
                        .font(.system(size: fontsize, design: .monospaced))
                    }
                    //.background(.orange)
                }
                .padding(.bottom, 20)
                // Back 9
                HStack(spacing: 0) {
                    ScoreRowHeader(playernames: players.map({ $0.name }), width: headerColumnWidth)
                    .font(.system(size: fontsize, design: .monospaced))
                    ScrollView(.horizontal, showsIndicators:false) {
                        VStack(alignment: .trailing) {
                            // Back9 Hole Row
                            ScoreGridTextRow(values: numberGridRow(holesBack9, width: colwidth))
                                .scoreBackground(type: .holes)
                                .foregroundColor(holeTextColor)
                            // Back9 Hcp Row
                            ScoreGridTextRow(values: numberGridRow(tee.handicaps(for: 9...17), width: colwidth))
                                .scoreBackground(type: .label)
                            // Back9 Strokes Empty Row
                            ScoreGridTextRow(values: ScorecardInnerView.emptyGridRow)
                            // Back9 player strokes and out row
                            ForEach(players) { player in
                                ScoreGridTextRow(values: stringGridRow(player.strokes(9...17, tee: tee), width: colwidth))
                            }
                            // Back9 Pars Row
                            ScoreGridTextRow(values: numberGridRow(tee.pars(for: 9...17), width: colwidth))
                                .scoreBackground(type: .label)
                            // Back9 Score Empty Row
                            ScoreGridTextRow(values: ScorecardInnerView.emptyGridRow)
                            // match/score
                            ForEach(players) { player in
                                ScoreGridTextRow(values: numberGridRow(player.scores(9...17, tee:tee), width: colwidth))
                            }
                        }
                        .font(.system(size: fontsize, design: .monospaced))
                    }
                    //.background(.green)

                }
                .padding(.bottom, 20)
                // Totals
                HStack(spacing: 0) {
                    SummaryRowHeader(playernames: players.map({ $0.name }), width: headerColumnWidth)
                    .font(.system(size: fontsize, design: .monospaced))
                    ScrollView(.horizontal, showsIndicators:false) {
                        VStack(alignment: .trailing) {
                            // Header  Row
                            ScoreGridTextRow(values: stringGridRow(["Out","In","Total","Hcp","Net"], width: summarywidth))
                                .scoreBackground(type: .holes)
                                .foregroundColor(holeTextColor)
                            // Totals Row
                            ScoreGridTextRow(values: numberGridRow([
                                tee.pars(for: 0...8).reduce(0, {$0 + $1}),
                                tee.pars(for: 9...17).reduce(0, {$0 + $1}),
                                tee.par,
                                0,
                                0]
                                , width: summarywidth))
                            .scoreBackground(type: .label)
                            // player total strokes
                            ForEach(players) { player in
                                ScoreGridTextRow(values: numberGridRow([player.outstrokes, player.instrokes, player.totalstrokes, player.hcp, player.totalstrokes - player.hcp], width: summarywidth))
                            }
                        }
                        .font(.system(size: fontsize, design: .monospaced))
                    }
//                    .background(.blue)
                }
            }
        }
//        .background(.red)
    }

    struct ScoreGridTextRow: View {
        let values: [NumberText]
        var body: some View {
            //Self._printChanges()
            return HStack {
                ForEach(values, id: \.id) { t in
                    Text("\(t.txt)")
                }
            }
        }
    }

    enum TextPadding {
        case leading
        case trailing
    }

    func padText(_ direction: TextPadding, str: String, width: Int) -> String {
        if direction == .leading {
            let tr = String(str.reversed())
            let trp = tr.padding(toLength: width, withPad: " ", startingAt: 0)
            return String(trp.reversed())
        } else {
            return str.padding(toLength: width, withPad: " ", startingAt: 0)
        }
    }

    func numberGridRow(_ numbers: [Int], width: Int) -> [NumberText] {
        var i = 0
        return numbers.map { i += 1; return NumberText(id: i, txt:padText(.leading, str:$0 > 0 ? $0 != .scoreIsZero ? String($0) : "0" : " ", width: width)) }
    }

    func stringGridRow(_ strings: [String], width: Int) -> [NumberText] {
        var i = 0
        return strings.map { i += 1; return NumberText(id: i, txt: padText(.leading, str: $0, width: width))}
    }

    static var emptyGridRow: [NumberText] {
        let s = Array(repeating:" ", count: 1)
        var i = 0
        return s.map { i += 1; return NumberText(id: i, txt:String($0)) }
    }
}

extension Color {
    public static var scoreBGLabel: Color {
        return Color("scbneutral")
    }
    public static var scoreBGData: Color {
        return Color("scbbackground")
    }
    public static var scoreBGHoles: Color {
        return Color("scbholes")
    }
    public static var scoreBGHandicap: Color {
        return Color("scbhandicap")
    }
    public static var scoreFGHandicap: Color {
        return Color("scfhandicap")
    }
}

enum ScoreGridRowType {
    case holes
    case label
    case data
    case handicap

    func color() -> Color {
        switch (self) {
        case .holes:
            return .scoreBGHoles
        case .label:
            return .scoreBGLabel
        case .data:
            return .scoreBGData
        case .handicap:
            return .scoreBGHandicap
        }
    }
}

struct ScoreBackgroundModifier: ViewModifier {
    var type: ScoreGridRowType
    func body(content: Content) -> some View {
        content
            .background(type.color())
    }
}

extension View {
    func scoreBackground(type: ScoreGridRowType) -> some View {
        modifier(ScoreBackgroundModifier(type: type))
    }
}

struct ScoreForgroundModifier: ViewModifier {
    var type: ScoreGridRowType
    func body(content: Content) -> some View {
        content
            .foregroundColor(type.color())
    }
}

extension View {
    func scoreForeground(type: ScoreGridRowType) -> some View {
        modifier(ScoreForgroundModifier(type: type))
    }
}
