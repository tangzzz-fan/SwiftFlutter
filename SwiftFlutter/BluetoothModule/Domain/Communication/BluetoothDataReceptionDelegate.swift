import CoreBluetooth
import Foundation

/// 蓝牙数据接收委托协议
protocol BluetoothDataReceptionDelegate: AnyObject {
    /// 当完整的数据包被接收时调用
    /// - Parameters:
    ///   - data: 接收到的完整数据
    ///   - peripheral: 数据来源的外围设备
    func didReceiveData(_ data: Data, from peripheral: CBPeripheral)
}
