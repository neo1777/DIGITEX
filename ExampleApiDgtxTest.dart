import 'dart:io' show WebSocket;
import 'dart:convert' show json;
import 'dart:core';
// ignore: unused_import
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:random_string/random_string.dart';

var req_id = 0;
// specify your own token
//var trader_token = 'SET_YOUR_TOKEN_HERE';
var trader_token = 'a22fa28b7122ee3fbb553483c43d2a89199acde9';
var trading_available = false;
Map open_contracts = {};
Map active_cond_orders = {};
Map active_orders = {};

Future round_price(price) async {
  var tick_size = 5;
  num n = (price / tick_size).round() * tick_size;
  return n;
}

String generate_id() {
  var rand = randomAlphaNumeric(16);
  return rand;
}

int next_req_id() {
  req_id++;
  return req_id;
}

Future send(ws, msg) async {
  print('sending: ${msg}');
  ws.add(msg);
}

Future send_request(ws, Map req) async {
  await send(ws, json.encode(req));
}

Future<Map> create_subscriptions_request(List<String> subscriptions) async {
  req_id = await next_req_id();
  var data = {'id': req_id, 'method': 'subscribe', 'params': subscriptions};
  return data;
}

Future handle_index_price(WebSocket ws, rsp) async {
  var px = rsp['data']['markPx'];
  var symbol = '';
  if (rsp['data']['indexSymbol'] == '.DGTXBTCUSD') {
    symbol = 'BTCUSD-PERP';
  } else if (rsp['data']['indexSymbol'] == '.DGTXETHUSD') {
    symbol = 'ETHUSD-PERP';
  }
  await handle_spot_price(ws, symbol, px);
}

Future handle_spot_price(WebSocket ws, String symbol, px) async {
  //print('spot symbol : ${symbol}');
  // make actiions according to 'symbol': currently it can be either BTCUSD-PERP or ETHUSD-PERP

  //var value = int.parse(randomNumeric(3));

  ////////////////////////////////////
  /*
  // some random condition
  // ---> Example of placing LIMIT order   // test ok
  if (value == 151) {
    print('spot value : ${value}');
    var side = randomChoice(['BUY', 'SELL']);
    var limit_px = 0.0;
    if (side == 'BUY')
      limit_px = px - 50;
    else
      limit_px = px + 50;
    var price_round = await round_price(limit_px);
    //print('$ws, $symbol, $side, $limit_px, ${price_round}');
    await place_limit_order(ws, symbol, side, price_round, 10, 'GTC');
  }
  // some random condition
  // ---> Example of cancelling order   // test ok

  if (value == 49) {
    print('spot value : ${value}');
    if (active_orders.isNotEmpty) {
      active_orders.forEach((key, value) async {
        var cl_ord_id = key;
        var symbol = value['symbol'];
        print('key: ${key}, value: $value, symbol: $symbol');
        cancel_order(ws, symbol, cl_ord_id);
      });
    }
  }

  */
  ////////////////////////////////////
  /*

  // ---> Example of placing conditional order   // test ok
  // some random condition
  if (value == 2) {
    print('spot value : ${value}');
    var order_to_place = {
      'clOrdId': generate_id(),
      'ordType': 'LIMIT',
      'timeInForce': 'GTC',
      'side': 'SELL',
      'px': 13000,
      'qty': 45,
      'mayIncrPosition': true
    };
    var action_id = generate_id();
    await place_conditional_order(ws, symbol, action_id, 'SPOT_PRICE',
        'GREATER_EQUAL', 13000, order_to_place);
  }

  // ---> Example of cancelling conditional order   // test ok
  // some random condition
  if (value == 7) {
    print('spot value : ${value}');
    if (active_cond_orders.length > 0) {
      //cancel a single conditional order
      //List list = [];
      //active_cond_orders.forEach((k, v) => list.add([k, v]));
      //for (var item in list) {
      //  var action_id = item[0];
      //  await cancel_conditional_order(ws, symbol, action_id, false);
      //  print('action_id: ${action_id}');
      //  return null;
      //}

      //cancel all conditional orders
      await cancel_conditional_order(ws, symbol, null, true);
    }
  }

  */
  ////////////////////////////////////
  /*

  // ---> Example of closing contract   // test ok
  // some random condition
  if (value == 196) {
    print('spot value : ${value}');
    if (open_contracts.length > 0) {
      // close a particular contract
      //List list = [];
      //open_contracts.forEach((k, v) => list.add([k, v]));
      //for (var item in list) {
      //  var contract_id = item[0];
      //  await close_contract(ws, symbol, contract_id, 'MARKET');
      //  print('contract_id: ${contract_id}');
      //  return null;
      //}

      //close all open contracts
      await close_position(ws, symbol, 'MARKET');
    }
  }
  
  */
}

Future handle_orderbook(WebSocket ws, msg) async {
  if (msg['data']['bids'].isEmpty && msg['data']['asks'].isEmpty) {
    return null;
  } else {
    var bids = msg['data']['bids'];
    var asks = msg['data']['asks'];
    var best_bid = bids[0];
    // ignore: unused_local_variable
    var best_bid_price = best_bid[0];
    //print('best bid px: ${best_bid_price}');
    var best_ask = asks[0];
    // ignore: unused_local_variable
    var best_ask_price = best_ask[0];
    //print('best ask px: ${best_ask_price}');
  }
}

Future handle_trades(ws, msg) async {
  List trades = msg['data']['trades'];
  trades.forEach((t) {
    // ignore: unused_local_variable
    var trade_price = t['px'];
    // ignore: unused_local_variable
    var trade_amount = t['qty'];
    //print('got trade: px=${trade_price}, qty=${trade_amount}');
  });
}

Future handle_kline(WebSocket ws, msg) async {
  var kline = msg['data'];
  // ignore: unused_local_variable
  var i = kline['interval'];
  // ignore: unused_local_variable
  var id = kline['id'];
  // ignore: unused_local_variable
  var o = kline['o'];
  // ignore: unused_local_variable
  var h = kline['h'];
  // ignore: unused_local_variable
  var l = kline['l'];
  // ignore: unused_local_variable
  var c = kline['c'];
  // ignore: unused_local_variable
  var v = kline['v'];
  //print(
  //'got kline: interval=${i}, id=${id}, open_px=${o}, high_px=${h}, low_px=${l}, close_px=${c}, volume=${v}');
}

Future handle_ticker(WebSocket ws, msg) async {
  var ticker = msg['data'];
  // ignore: unused_local_variable
  var open_ts = ticker['openTime'];
  // ignore: unused_local_variable
  var close_ts = ticker['closeTime'];
  // ignore: unused_local_variable
  var high_px = ticker['highPx24h'];
  // ignore: unused_local_variable
  var low_px = ticker['lowPx24h'];
  // ignore: unused_local_variable
  var px_change = ticker['pxChange24h'];
  // ignore: unused_local_variable
  var volume24h = ticker['volume24h'];
  // ignore: unused_local_variable
  var funding_rate = ticker['fundingRate'];
  // ignore: unused_local_variable
  var contract_value = ticker['contractValue'];
  // ignore: unused_local_variable
  var dgtx_rate = ticker['dgtxUsdRate'];
  //print('got 24 stats: from=${open_ts} to=${close_ts} high_price=${high_px} '
  //'low_price=${low_px} price_change=${px_change} volume=${volume24h} '
  //'funding_rate=${funding_rate} contract_value=${contract_value} DGTX/USD=${dgtx_rate}');
}

Future handle_exchange_message(WebSocket ws, Map resp) async {
  var msg = resp['ch'].toString();
  if (msg.startsWith('orderbook')) {
    msg = 'orderbook';
  }
  if (msg.startsWith('kline')) {
    msg = 'kline';
  }
  try {
    switch (msg) {
      case 'index':
        {
          await handle_index_price(ws, resp);
        }
        break;
      case 'orderbook':
        {
          await handle_orderbook(ws, resp);
        }
        break;
      case 'trades':
        {
          await handle_trades(ws, resp);
        }
        break;
      case 'kline':
        {
          await handle_kline(ws, resp);
        }
        break;
      case 'ticker':
        {
          await handle_ticker(ws, resp);
        }
        break;
      case 'orderStatus':
        {
          await handle_order_status(ws, resp);
        }
        break;
      case 'orderFilled':
        {
          await handle_order_filled(ws, resp);
        }
        break;
      case 'orderCancelled':
        {
          await handle_order_cancelled(ws, resp);
        }
        break;
      case 'traderStatus':
        {
          await handle_trader_status(ws, resp);
        }
        break;
      case 'error':
        {
          await handle_error(ws, resp);
        }
        break;
      case 'contractClosed':
        {
          await handle_contract_closed(ws, resp);
        }
        break;
      case 'condOrderStatus':
        {
          await handle_conditional_order_status(ws, resp);
        }
        break;
      case 'leverage':
        {
          await handle_leverage(ws, resp);
        }
        break;
      case 'funding':
        {
          await handle_funding(ws, resp);
        }
        break;
      case 'tradingStatus':
        {
          await handle_trading_status(ws, resp);
        }
        break;

      default:
        {
          print('unhandled message: ${resp.toString()}');
        }
        break;
    }
  } catch (e) {
    print('WARNING! Exception: ${e}, status: $msg');
  }
}

Future authenticate(WebSocket ws, token) async {
  var auth_req_id;

  if (token == null) {
    print('invalid token');
    return null;
  }

  auth_req_id = next_req_id();
  Map req;
  req = {
    'id': auth_req_id,
    'method': 'auth',
    'params': {'type': 'token', 'value': token}
  };
  print('authenticating with provided token');
  await send_request(ws, req);
}

Future get_trader_status(WebSocket ws) async {
  var req = {
    'id': next_req_id(),
    'method': 'getTraderStatus',
    'params': {'symbol': 'BTCUSD-PERP'}
  };
  print('requesting trader status');
  await send_request(ws, req);
}

Future handle_trader_status(WebSocket ws, msg) async {
  var data = msg['data'];

  var trader_balance = data['traderBalance'];
  print('trader balance: ${trader_balance}');

  if (data.containsKey('positionType')) {
    var total_contracts = data['positionContracts'];
    var pos_type = data['positionType'];
    print('trader position: ${pos_type}@${total_contracts}');
  }
  open_contracts = {};
  if (data.containsKey('contracts')) {
    List contractlist = data['contracts'];
    contractlist.forEach((c) {
      var contract_id = c['contractId'];
      open_contracts[contract_id] = c;
    });
    print('open contracts: ${open_contracts}');
  }

  var symbol = data['symbol'];
  if (data.containsKey('activeOrders')) {
    List orderlist = data['activeOrders'];
    orderlist.forEach((o) {
      var cl_ord_id = o['clOrdId'];
      var ord_type = o['orderType'];
      var ord_side = o['orderSide'];
      var ord_tif = o['timeInForce'];
      var px;
      if (o.containsKey('px')) {
        px = o['px'];
      } else {
        px = 0.0;
      }
      var qty = o['qty'];

      var res = {
        'symbol': symbol,
        'orderType': ord_type,
        'side': ord_side,
        'ti': ord_tif,
        'px': px,
        'qty': qty
      };
      active_orders['$cl_ord_id'] = res;
    });

    print('active_orders handle_trader_status: $active_orders');
  }

  if (data.containsKey('conditionalOrders')) {
    List cond_orderlist = data['conditionalOrders'];
    cond_orderlist.forEach((co) {
      var action_id = co['actionId'];
      active_cond_orders[action_id] = co;
    });
  }
  print('active conditional orders: $active_cond_orders');
}

// usage:
//      place_market_order(ws, symbol=symbol, side='BUY', amount=100, tif='FOK')
Future place_market_order(ws, symbol, side, amount, tif) async {
  var order_id = generate_id();
  var params = {
    'symbol': symbol,
    'clOrdId': order_id,
    'ordType': 'MARKET',
    'timeInForce': tif,
    'side': side,
    'qty': amount
  };
  var req = {'id': next_req_id(), 'method': 'placeOrder', 'params': params};
  print('placing MARKET order: $params');
  await send_request(ws, req);
}

// usage:
//      place_limit_order(ws, symbol='BTCUSD-PERP', side='BUY', price=9250, amount=100, tif='GTC')
Future place_limit_order(ws, symbol, side, price, amount, tif) async {
  var order_id = generate_id();
  var params = {
    'symbol': symbol,
    'clOrdId': order_id,
    'ordType': 'LIMIT',
    'timeInForce': tif,
    'side': side,
    'px': price,
    'qty': amount
  };
  var req = {'id': next_req_id(), 'method': 'placeOrder', 'params': params};
  print('placing LIMIT order: $params');
  await send_request(ws, req);
}

// usage:
//      cancel_order(ws, symbol='BTCUSD-PERP', 'sRJiP18rwdhukaxd')
Future cancel_order(ws, symbol, cl_ord_id) async {
  var params = {'symbol': symbol, 'clOrdId': cl_ord_id};
  var req = {'id': next_req_id(), 'method': 'cancelOrder', 'params': params};
  print('cancelling order: ${cl_ord_id}');
  await send_request(ws, req);
}

// usage:
//      cancel_all_orders(ws, symbol='BTCUSD-PERP', side='SELL') - cancel all SELL orders
Future cancel_all_orders(ws, symbol, {side, price}) async {
  var params = {'symbol': symbol};
  if (side != null) {
    params['side'] = side;
  }
  if (price != null) {
    params['px'] = round_price(price);
  }
  var req = {
    'id': next_req_id(),
    'method': 'cancelAllOrders',
    'params': params
  };
  print('cancelling ALL orders');
  await send_request(ws, req);
}

// usage:
//      close_contract(ws, 'BTCUSD-PERP', 619920760, 'MARKET') - close contract 619920760 with market order
//      close_contract(ws, 'BTCUSD-PERP', 619920760, 'LIMIT', 9250, 50) - close only part of the contract 619920760 with limit order
Future close_contract(ws, symbol, contract_id, ord_type, {price, qty}) async {
  var params = {
    'symbol': symbol,
    'contractId': contract_id,
    'ordType': ord_type
  };
  if (ord_type == 'LIMIT') {
    if (price == null) {
      print('LIMIT order must specify a price');
      return null;
    }
    params['px'] = round_price(price);
  }
  if (ord_type != null) {
    params['qty'] = qty;
  }
  var req = {'id': next_req_id(), 'method': 'closeContract', 'params': params};
  print('closing contract: ${contract_id}');
  await send_request(ws, req);
}

// usage:
//      pass 'price' if the 'ord_type' is 'LIMIT'
Future close_position(ws, symbol, ord_type, {price}) async {
  if (ord_type == 'LIMIT' && price == null) {
    print('price must be specified for LIMIT order');
    return null;
  }
  var params = {'symbol': symbol, 'ordType': ord_type};
  if (price != null) {
    params['px'] = price;
  }
  var req = {'id': next_req_id(), 'method': 'closePosition', 'params': params};
  print('closing position');
  await send_request(ws, req);
}

// parameters:
// - action_id - generated unique ID of the conditional action
// - trigger_price - currently only 'SPOT_PRICE' supported
// - trigger_cond - 'GREATER_EQUAL' or 'LESS_EQUAL'
// - trigger_val - price value for the condition
// - order_data - conditional order parameters: type, side, TIF, ID, price, quantity:
// {'clOrdId':'010e2b91e5214410', 'ordType':'LIMIT', 'timeInForce':'GTC', 'side':'BUY', 'px':9105, 'qty':100, 'mayIncrPosition': true}

Future place_conditional_order(ws, symbol, action_id, trigger_price,
    trigger_cond, trigger_val, Map order_data) async {
  var params = {
    'symbol': symbol,
    'actionId': action_id,
    'pxType': trigger_price,
    'condition': trigger_cond,
    'pxValue': trigger_val.round()
  };
  order_data.forEach((key, value) {
    params[key] = value;
  });
  var req = {'id': next_req_id(), 'method': 'placeCondOrder', 'params': params};
  print('placing conditional order: $params');
  await send_request(ws, req);
}

// usage:
//      cancel_conditional_order(ws, 'BTCUSD-PERP', 'a5b90ca768754b75', all=False)
Future cancel_conditional_order(ws, symbol, action_id, all) async {
  if (action_id == null && all == false) {
    print(
        'attempt to cancel conditional order: either $action_id should be specified or $all set to True');
    return null;
  }

  var params = {'symbol': symbol};
  if (action_id != null) {
    print('cancelling conditional order: ${action_id}');
    params['actionId'] = action_id;
  }
  if (all) {
    print('cancelling ALL conditional orders');
    params['allForTrader'] = true;
  }
  var req = {
    'id': next_req_id(),
    'method': 'cancelCondOrder',
    'params': params
  };
  await send_request(ws, req);
}

Future change_leverage(ws, symbol, value) async {
  print('changing traders leverage to ${value}');
  var params = {'symbol': symbol, 'leverage': value};
  var req = {
    'id': next_req_id(),
    'method': 'changeLeverageAll',
    'params': params
  };
  await send_request(ws, req);
}

Future handle_order_status(WebSocket ws, msg) async {
  var data = msg['data'];
  var cl_ord_id = data['clOrdId'];
  var status = data['orderStatus'];
  if (status == 'ACCEPTED') {
    var symbol = data['symbol'];
    var ord_type = data['orderType'];
    var ord_side = data['orderSide'];
    var ord_tif = data['timeInForce'];
    var px = data['px'];
    var qty = data['qty'];
    if (ord_type == 'LIMIT') {
      print(
          'order ${cl_ord_id} has been ACCEPTED: ${symbol} ${ord_type} ${ord_tif} ${ord_side} ${qty} @ ${px}');
    } else {
      print(
          'order ${cl_ord_id} has been ACCEPTED: ${symbol} ${ord_type} ${ord_tif} ${ord_side} ${qty}');
    }

    var res = {
      'symbol': symbol,
      'orderType': ord_type,
      'side': ord_side,
      'ti': ord_tif,
      'px': px,
      'qty': qty
    };
    active_orders['$cl_ord_id'] = res;
  } else if (status == 'REJECTED' && data.containsKey('errCode')) {
    var error_code = data['errCode'];
    print(
        'order ${cl_ord_id} has been REJECTED with error code: ${error_code}');
  } else {
    print('order ${cl_ord_id} has been ${status}');
  }

  print('active orders handle_order_status: ${active_orders}');
}

Future handle_order_filled(WebSocket ws, msg) async {
  var data = msg['data'];
  var filled_ord_id = data['clOrdId'];
  var order_status = data['orderStatus'];

  if (order_status == 'FILLED') {
    print('order ${filled_ord_id} has been FILLED');
  } else if (order_status == 'PARTIALLY_FILLED') {
    print('order ${filled_ord_id} has been PARTIALLY FILLED');
  } else {
    print('order ${filled_ord_id} has status: ${order_status}');
  }

  if (active_orders.containsKey('$filled_ord_id')) {
    await active_orders.remove(filled_ord_id);
  }

  print('active orders handle_order_filled: ${active_orders}');

  open_contracts = {};
  List contracts = data['contracts'];
  contracts.forEach((c) {
    var contract_id = c['contractId'];
    var qty = c['qty'];
    if (qty > 0) {
      open_contracts[contract_id] = c;
      var pos_type = c['positionType'];
      var entry_px = c['entryPx'];
      print(
          'new contract ${contract_id}: ${pos_type} entry_px=${entry_px} qty=${qty}');
    } else if (qty == 0) {
      var closed_contract_id = c['oldContractId'];
      var exit_px = c['exitPx'];
      print('contract ${closed_contract_id} has been closed at ${exit_px}');
      if (open_contracts.containsKey('closed_contract_id')) {
        open_contracts.remove(closed_contract_id);
      }
    }

    var trader_balance = data['traderBalance'];
    print('trader balance: ${trader_balance}');
    if (data.containsKey('positionType')) {
      var pos_type = data['positionType'];
      var total_contracts = data['positionContracts'];
      print('trader position: ${pos_type}@${total_contracts}');
    }
  });
}

Future handle_order_cancelled(WebSocket ws, msg) async {
  Map data = msg['data'];
  var status = data['orderStatus'];

  if (status == 'REJECTED' && data.containsKey('errCode')) {
    var error_code = data['errCode'];
    print('order cancellation REJECTED with error code: ${error_code}');
    return null;
  }

  if (data.containsKey('errCode')) {
    return null;
  }

  data['orders'].forEach((order) async {
    var cancelled_order_id = order['oldClOrdId'];
    print('order ${cancelled_order_id} has been CANCELLED');

    if (active_orders.containsKey('$cancelled_order_id')) {
      active_orders.remove(cancelled_order_id);
    }
  });

  print('active orders handle_order_cancelled: ${active_orders}');
}

Future handle_contract_closed(WebSocket ws, msg) async {
  print(msg);

  var data = msg['data'];
  if (data.containsKey('errCode')) {
    var error_code = data['errCode'];
    print('contract close operation FAILED with error code: ${error_code}');
  }
}

Future handle_conditional_order_status(WebSocket ws, msg) async {
  var data = msg['data'];
  var status = data['status'];

  if (data.containsKey('errCode')) {
    var error_code = data['errCode'];
    print(
        'conditional order placement/cancellation FAILED with error code: ${error_code}');
    return null;
  }

  if (status == 'ACCEPTED') {
    data['conditionalOrders'].forEach((co) {
      var action_id = co['actionId'];
      active_cond_orders[action_id] = co;
      print('conditional order ${action_id}: ${status}');
    });
  } else if (status != 'PENDING') {
    data['conditionalOrders'].forEach((co) {
      var action_id = co['oldActionId'];

      if (active_cond_orders.containsKey('$action_id')) {
        active_cond_orders.remove(action_id);
      }

      print('conditional order ${action_id}: ${status}');
    });
  }

  print(
      'active conditional orders handle_conditional_order_status: $active_cond_orders');
}

Future handle_leverage(WebSocket ws, msg) async {
  var data = msg['data'];
  var leverage = data['leverage'];
  print('trader leverage now is: ${leverage}');
  if (data.containsKey('errCode')) {
    var error_code = data['errCode'];
    print('leverage change FAILED with error code: ${error_code}');
    return null;
  }

  var trader_balance = data['traderBalance'];
  print('trader balance: ${trader_balance}');

  if (data.containsKey('positionType')) {
    var total_contracts = data['positionContracts'];
    var pos_type = data['positionType'];
    print('trader position: ${pos_type}@${total_contracts}');
  }

  open_contracts = {};
  if (data.containsKey('contracts')) {
    List contractlist = data['contracts'];
    contractlist.forEach((c) {
      var contract_id = c['contractId'];
      open_contracts[contract_id] = c;
    });
    print('open contracts: $open_contracts');
  }

  active_orders = {};
  var symbol = data['symbol'];
  if (data.containsKey('activeOrders')) {
    List orderlist = data['activeOrders'];
    orderlist.forEach((o) {
      var cl_ord_id = o['clOrdId'];
      var ord_type = o['orderType'];
      var ord_side = o['orderSide'];
      var ord_tif = o['timeInForce'];
      var px = o['px']; //if 'px' in o else 0.0;
      var qty = o['qty'];
      active_orders[cl_ord_id] = {
        'symbol': symbol,
        'orderType': ord_type,
        'side': ord_side,
        'ti': ord_tif,
        'px': px,
        'qty': qty
      };
    });

    print('active_orders handle_leverage: $active_orders');
  }
}

Future handle_funding(WebSocket ws, msg) async {
  var data = msg['data'];
  // ignore: unused_local_variable
  var symbol = data['symbol'];
  var trader_balance = data['traderBalance'];
  var payout = data['payout'];
  var pos_margin_change = data['positionMarginChange'];
  print(
      'trader balance = ${trader_balance}, payout = ${payout}, position margin change = ${pos_margin_change}');

  if (data.containsKey('contracts')) {
    List contractlist = data['contracts'];
    contractlist.forEach((element) {
      print('open contracts handle_funding: ${element}');
    });
  }
}

Future handle_trading_status(WebSocket ws, msg) async {
  var data = msg['data'];
  if (data['available'] == true) {
    // trading is available
    // trade requests can be sent
    trading_available = true;
    print('trading: AVAILABLE');
    await get_trader_status(ws);
  } else {
    trading_available = false;
    print('trading: NOT AVAILABLE');
  }
}

Future handle_error(WebSocket ws, msg) async {
  print(msg);
}

Future run() async {
  // ignore: unused_local_variable
  var urlReal = 'wss://ws.mapi.digitexfutures.com';
  //var urlTest = 'wss://ws.tapi.digitexfutures.com';
  var urlTest = 'wss://ws.testnet.digitex.fun';

  Future req_1 = create_subscriptions_request([
    'BTCUSD-PERP@index',
    'BTCUSD-PERP@orderbook_5',
    'BTCUSD-PERP@ticker',
    'BTCUSD-PERP@trades',
    'BTCUSD-PERP@liquidations'
  ]);
  var req = await req_1;
  await WebSocket.connect(urlTest).then((WebSocket ws) async {
    await send_request(ws, req);
    await authenticate(ws, trader_token);

    ws.listen((msg) async {
      if (msg.toString() == 'ping') {
        print('received: ping');
        await send(ws, 'pong');
      } else {
        Map response = json.decode(msg.toString());
        if (response.containsKey('ch')) {
          await handle_exchange_message(ws, response);
        } else {
          print('received: ${response}');
        }
      }
    });
  });
}

void main(List<String> args) async {
  await run();
}
