import ComposableArchitecture
import SwiftUI

private let readMe = """
  This demonstrates how to best handle alerts and action sheets in the Composable Architecture.

  Because the library demands that all data flow through the application in a single direction, \
  we cannot leverage SwiftUI's two-way bindings since they allow making changes to state without \
  going through a reducer. This means we can't directly use the standard API for display alerts \
  and sheets.

  However, the library comes with two types, `AlertState` and `ActionSheetState`, which can be \
  constructed from reducers that control whether or not an alert or action sheet is displayed. \
  Further, it automatically handles sending actions when you tap their buttons, which allows you \
  to properly handle their functionality in the reducer rather than in two-way bindings and \
  action closures.

  The benefit of doing this is that you can get full test coverage on how a user interacts with \
  with alerts and action sheets in your application
  """

struct AlertsAndActionSheetsState: Equatable {
  var actionSheet = ActionSheetState<AlertsAndActionSheetsAction>.dismissed
  var alert = AlertState<AlertsAndActionSheetsAction>.dismissed
  var count = 0
}

enum AlertsAndActionSheetsAction: Equatable {
  case actionSheetButtonTapped
  case actionSheetCancelTapped
  case alertButtonTapped
  case alertCancelTapped
  case decrementButtonTapped
  case incrementButtonTapped
}

struct AlertsAndActionSheetsEnvironment {}

let alertsAndActionSheetsReducer = Reducer<AlertsAndActionSheetsState, AlertsAndActionSheetsAction, AlertsAndActionSheetsEnvironment> { state, action, _ in

  switch action {
  case .actionSheetButtonTapped:
    state.actionSheet = .show(
      .init(
        buttons: [
          .init(
            action: .actionSheetCancelTapped,
            label: "Cancel",
            type: .cancel
          ),
          .init(
            action: .incrementButtonTapped,
            label: "Increment",
            type: .default
          ),
          .init(
            action: .decrementButtonTapped,
            label: "Decrement",
            type: .default
          ),
        ],
        message: "This is an action sheet.",
        title: "Action sheet"
      )
    )
    return .none

  case .actionSheetCancelTapped:
    state.actionSheet = .dismissed
    return .none

  case .alertButtonTapped:
    state.alert = .show(
      .init(
        message: "This is an alert",
        primaryButton: .init(
          action: .alertCancelTapped,
          label: "Cancel",
          type: .cancel
        ),
        secondaryButton: .init(
          action: .incrementButtonTapped,
          label: "Increment",
          type: .default
        ),
        title: "Aert!"
      )
    )
    return .none

  case .alertCancelTapped:
    state.alert = .dismissed
    return .none

  case .decrementButtonTapped:
    state.count -= 1
    return .none

  case .incrementButtonTapped:
    state.count += 1
    return .none
  }
}

struct AlertsAndActionSheetsView: View {
  let store: Store<AlertsAndActionSheetsState, AlertsAndActionSheetsAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(header: Text(template: readMe, .caption).textCase(.none)) {
          Text("Count: \(viewStore.count)")

          Button("Alert") { viewStore.send(.alertButtonTapped) }
            .alert(
              viewStore.alert,
              send: viewStore.send,
              dismissal: .alertCancelTapped
            )

          Button("Action sheet") { viewStore.send(.actionSheetButtonTapped) }
            .actionSheet(
              viewStore.actionSheet,
              send: viewStore.send,
              dismissal: .actionSheetCancelTapped
            )
        }
      }
    }
    .navigationTitle("Alerts & Action Sheets")
  }
}

struct AlertsAndActionSheets_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
    AlertsAndActionSheetsView(
      store: .init(
        initialState: .init(),
        reducer: alertsAndActionSheetsReducer,
        environment: .init()
      )
    )
    }
  }
}
