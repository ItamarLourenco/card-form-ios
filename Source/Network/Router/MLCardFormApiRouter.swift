//
//  MLCardFormApiRouter.swift
//  CardForm
//
//  Created by Juan sebastian Sanzone on 10/30/19.
//  Copyright © 2019 JS. All rights reserved.
//

import Foundation

enum MLCardFormApiRouter {

    case getCardData(MLCardFormBinService.QueryParams, MLCardFormBinService.Headers)
    case postCardTokenData(MLCardFormAddCardService.KeyParam, MLCardFormAddCardService.Headers, MLCardFormTokenizationBody)
    case postCardData(MLCardFormAddCardService.AddCardParams, MLCardFormAddCardService.Headers, MLCardFormAddCardBody)
    case getWebPayInitInscription(MLCardFormWebPayService.AddCardParams, MLCardFormWebPayService.Headers)
    case postWebPayFinishInscription(MLCardFormWebPayService.Headers, MLCardFormFinishInscriptionBody)
    case postWebPayCardTokenData(MLCardFormWebPayService.KeyParam, MLCardFormWebPayService.Headers, MLCardFormWebPayTokenizationBody)

    var scheme: String {
        switch self {
        case .getCardData, .postCardTokenData, .postCardData:
            return "https"
        case .getWebPayInitInscription, .postWebPayFinishInscription, .postWebPayCardTokenData:
            return "http"
        }
    }

    var host: String {
        switch self {
        case .getCardData, .postCardTokenData, .postCardData:
            return "api.mercadopago.com"
        case .getWebPayInitInscription, .postWebPayFinishInscription, .postWebPayCardTokenData:
            return "api.mp.internal.ml.com"
        }
    }

    var path: String {
        switch self {
        case .getCardData:
            return "/production/px_mobile/v1/card"
        case .postCardTokenData:
            return "/v1/card_tokens"
        case .postWebPayCardTokenData:
            return "/gateway/staging/card_tokens"
        case .postCardData:
            return "/gamma/px_mobile/v1/card" //"/production/px_mobile/v1/card"
        case .getWebPayInitInscription:
            return "/gamma/px_mobile/v1/card_webpay/inscription/init"
        case .postWebPayFinishInscription:
            return "/g2/staging/integration/transbank-webpay-oneclick/finish_inscription"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getCardData(_ , let headers):
            return [MLCardFormBinService.HeadersKeys.userAgent.getKey: headers.userAgent,
                    MLCardFormBinService.HeadersKeys.xDensity.getKey: headers.xDensity,
                    MLCardFormBinService.HeadersKeys.acceptLanguage.getKey: headers.acceptLanguage,
                    MLCardFormBinService.HeadersKeys.xProductId.getKey: headers.xProductId]
        case .postCardTokenData(_, let headers, _),
             .postCardData(_, let headers, _):
            return [MLCardFormAddCardService.HeadersKeys.contentType.getKey: headers.contentType]
        case .getWebPayInitInscription(_, let headers):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormWebPayService.HeadersKeys.xpublic.getKey: headers.xpublic]
        case .postWebPayFinishInscription(let headers, _):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType]
        case .postWebPayCardTokenData(_, let headers, _):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType]
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .getCardData(let queryParams, _):
            var urlQueryItems = [
                URLQueryItem(name: MLCardFormBinService.QueryKeys.bin.getKey, value: queryParams.bin),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.siteId.getKey, value: queryParams.siteId),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.platform.getKey, value: queryParams.platform),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.odr.getKey, value: String(queryParams.odr))
            ]
            if let excludedPaymentTypes = queryParams.excludedPaymentTypes {
                urlQueryItems.append(URLQueryItem(name: MLCardFormBinService.QueryKeys.excludedPaymentTypes.getKey, value: excludedPaymentTypes))
            }
            return urlQueryItems
        case.postCardTokenData(let queryParams, _, _):
            var urlQueryItems:[URLQueryItem] = []
            if let accessToken = queryParams.accessToken {
                urlQueryItems.append(URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: accessToken))
            } else if let publicKey = queryParams.publicKey {
                urlQueryItems.append(URLQueryItem(name: MLCardFormAddCardService.QueryKeys.publicKey.getKey, value: publicKey))
            }
            return urlQueryItems
        case .postCardData(let queryParams, _, _):
            let urlQueryItems = [
                URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: queryParams.accessToken),
            ]
            return urlQueryItems
        case .getWebPayInitInscription(let queryParams, _):
            let urlQueryItems = [
                URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: queryParams.accessToken),
            ]
            return urlQueryItems
        case .postWebPayFinishInscription(_, _):
            return []
        case .postWebPayCardTokenData(let queryParams, _, _):
            var urlQueryItems:[URLQueryItem] = []
            if let accessToken = queryParams.accessToken {
                urlQueryItems.append(URLQueryItem(name: MLCardFormWebPayService.QueryKeys.accessToken.getKey, value: accessToken))
            } else if let publicKey = queryParams.publicKey {
                urlQueryItems.append(URLQueryItem(name: MLCardFormWebPayService.QueryKeys.publicKey.getKey, value: publicKey))
            }
            return urlQueryItems
        }
    }

    var method: String {
        switch self {
        case .getCardData,
             .getWebPayInitInscription:
            return "GET"
        case .postCardTokenData,
             .postCardData,
             .postWebPayFinishInscription,
             .postWebPayCardTokenData:
            return "POST"
        }
    }

    var body: Data? {
        switch self {
        case .postCardTokenData(_, _, let body):
            return encode(body)
        case .postCardData(_, _, let body):
            return encode(body)
        case .postWebPayFinishInscription(_, let body):
            return encode(body)
        case .postWebPayCardTokenData(_, _, let body):
            return encode(body)
        default:
            return nil
        }
    }
}

// MARK: Encoding
private extension MLCardFormApiRouter {
    func encode<T: Codable>(_ body: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(body)
        return body
    }
}
