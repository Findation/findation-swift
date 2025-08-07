import SwiftUI

struct UIKitRoutineListView: UIViewControllerRepresentable {
    @Binding var routines: [Routine]

    // 콜백들 - SwiftUI에서 전달받음
    var onLongPressComplete: ((Routine) -> Void)? = nil
    var onEdit: ((Routine) -> Void)? = nil
    var onDelete: ((Routine) -> Void)? = nil
    var onComplete: ((Routine) -> Void)? = nil

    func makeUIViewController(context: Context) -> RoutineListViewController {
        let vc = RoutineListViewController()
        vc.routines = routines

        // 콜백 연결
        vc.onLongPress = onLongPressComplete
        vc.onEdit = onEdit
        vc.onDelete = onDelete
        vc.onComplete = onComplete

        return vc
    }

    func updateUIViewController(_ uiViewController: RoutineListViewController, context: Context) {
        uiViewController.routines = routines
        uiViewController.tableView.reloadData()
    }
}
