//
//  File.swift
//  
//
//  Created by Balik on 09.04.2024.
//
// Cодержит методы для обработки обновлений, сообщений, команд и действий бота. Это включает в себя методы типа defaultBaseHandler, messageHandler, commandPingHandler, commandShowButtonsHandler и buttonsActionHandler.

import Vapor
import TelegramVaporBot

final class DefaultBotHandlers {

    static func addHandlers(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await defaultBaseHandler(app: app, connection: connection)
        await messageHandler(app: app, connection: connection)
        await commandPingHandler(app: app, connection: connection)
        await commandShowButtonsHandler(app: app, connection: connection)
        await buttonsActionHandler(app: app, connection: connection)
    }
    
    /// Handler for all updates
//    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGBaseHandler({ update, bot in
//            guard let message = update.message else { return }
//            let params: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: "TGBaseHandler")
//            try await connection.bot.sendMessage(params: params)
//        }))
//    }
    
    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {

            await connection.dispatcher.add(TGBaseHandler { update, bot in
                guard let userId = update.message?.from?.id else { return }

                // Текст приветствия
                let welcomeMessage = """
                🤖 Добро пожаловать на презентацию проекта RoadMap!\n 🚀 RoadMap - "Это имитация рабочего процесса:\n 👨🏻‍💻Наше обучение представляет собой полную имитацию рабочего процесса, основанную на методике Scrum.\n 🏃‍♂️ За пять месяцев интенсивного обучения вы освоите разработку на Swift, создадите более 15 проектов и разработаете проект для вашего портфолио.\n🧩 Подготовка к будущему:\n Мы гарантируем, что после завершения курса вы будете готовы успешно пройти собеседование в любой компании на рынке IT.\n✊ Этот курс - ваш первый шаг к востребованной карьере в мире разработки. Это наше меню.\n\n
              📖 К вашему вниманию меню:
              """

                // Создание кнопок
                let buttons: [[TGInlineKeyboardButton]] = [
                    [.init(text: "🌏 Узнать больше о роадмапе на сайте", callbackData: "/web_site")],
                    [.init(text: "👨🏻‍💻 Получить вступительное тестовое задание", callbackData: "/send_file_with_button")]
                ]

                // Создание разметки с кнопками
                let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
                
                // Параметры сообщения с изображением и кнопками
                let params = TGSendPhotoParams(
                    chatId: .chat(userId),
                    photo: .url("https://disk.yandex.ru/i/q8WgWkEpRlF7xQ"),
                    caption: welcomeMessage,
                    replyMarkup: .inlineKeyboardMarkup(keyboard)
                )

                // Отправка сообщения с изображением и кнопками
                do {
                    try await connection.bot.sendPhoto(params: params)
                } catch {
                    print("Failed to send message with image and buttons: \(error)")
                }
            })
        }
    
    /// Handler for buttons callbacks
    private static func buttonsActionHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "/web_site") { update, bot in
            guard let callbackQuery = update.callbackQuery else { return }
            
            let link = "https://sites.google.com/view/roadmap-ios/главная-страница"
            let buttonText = "Открыть сайт"
            let button = TGInlineKeyboardButton(text: buttonText, url: link)
            let keyboardMarkup = TGInlineKeyboardMarkup(inlineKeyboard: [[button]])
            
            let params = TGSendMessageParams(
                chatId: .chat(callbackQuery.message?.chat.id ?? 0),
                text: "Привет! Вот ссылка на наш сайт:",
                replyMarkup: .inlineKeyboardMarkup(keyboardMarkup)
            )
            
            do {
                try await bot.sendMessage(params: params)
            } catch {
                print("Failed to send message with website link: \(error)")
            }
        })
        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "/send_file_with_button") { update, bot in
            guard let callbackQuery = update.callbackQuery else { return }
            
            let chatId: Int64 = callbackQuery.message?.chat.id ?? 0
            
            // Ссылка на Google Диск
            let googleDriveLink = "https://disk.yandex.ru/i/jBYRyEuBvVaMkQ"
            
            // Создаем кнопку для вступления в чат
            let joinChatButton = TGInlineKeyboardButton(text: "Вступить в чат выполнения тестового", url: "https://t.me/+fTcJSyJHOVQzNzdi")
            
            // Создаем кнопку для ссылки на Google Диск
            let driveButton = TGInlineKeyboardButton(text: "Скачать тестовое", url: googleDriveLink)
            
            // Создаем разметку с кнопками
            let keyboardMarkup = TGInlineKeyboardMarkup(inlineKeyboard: [[joinChatButton], [driveButton]])
            
            let messageText = """
            Высылаю тестовое
            минимальный бал - 16 (задания окрашены в зеленый цвет) остальные по желанию
            срок выполнения 6 дней с момента получения задания.
            Нужно скачать тестовое по кнопке и вступить в группу для его выполнения.
            """
            
            // Параметры сообщения с кнопками
            let messageParams = TGSendMessageParams(chatId: .chat(chatId), text: messageText, replyMarkup: .inlineKeyboardMarkup(keyboardMarkup))
            
            // Отправляем сообщение с кнопками
            do {
                try await bot.sendMessage(params: messageParams)
            } catch {
                print("Failed to send message with buttons: \(error)")
            }
        })
    }

    /// Handler for Messages
    private static func messageHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update, bot in
            let params: TGSendMessageParams = .init(chatId: .chat(update.message!.chat.id), text: "Success")
            try await connection.bot.sendMessage(params: params)
        })
    }

    /// Handler for Commands
    private static func commandPingHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: ["/ping"]) { update, bot in
            try await update.message?.reply(text: "pong", bot: bot)
        })
    }

    /// Show buttons
    private static func commandShowButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: ["/show_buttons"]) { update, bot in
            guard let userId = update.message?.from?.id else { fatalError("user id not found") }
            let buttons: [[TGInlineKeyboardButton]] = [
                [.init(text: "Button 1", callbackData: "press 1"), .init(text: "Button 2", callbackData: "press 2")]
            ]
            let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
            let params: TGSendMessageParams = .init(chatId: .chat(userId),
                                                    text: "Keyboard active",
                                                    replyMarkup: .inlineKeyboardMarkup(keyboard))
            try await connection.bot.sendMessage(params: params)
        })
    }

    /// Handler for buttons callbacks
//    private static func buttonsActionHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "press 1") { update, bot in
//            let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
//                                                            text: update.callbackQuery?.data  ?? "data not exist",
//                                                            showAlert: nil,
//                                                            url: nil,
//                                                            cacheTime: nil)
//            try await bot.answerCallbackQuery(params: params)
//        })
//        
//        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "press 2") { update, bot in
//            let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
//                                                            text: update.callbackQuery?.data  ?? "data not exist",
//                                                            showAlert: nil,
//                                                            url: nil,
//                                                            cacheTime: nil)
//            try await bot.answerCallbackQuery(params: params)
//        })
//    }
}
