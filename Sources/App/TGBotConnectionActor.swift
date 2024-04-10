//
//  File.swift
//  
//
//  Created by Balik on 09.04.2024.
//

/// Этот актор будет использоваться для управления подключением бота.

import Foundation
import TelegramVaporBot

actor TGBotConnection {
    private var _connection: TGConnectionPrtcl!

    var connection: TGConnectionPrtcl {
        self._connection
    }
    
    func setConnection(_ conn: TGConnectionPrtcl) {
        self._connection = conn
    }
}
