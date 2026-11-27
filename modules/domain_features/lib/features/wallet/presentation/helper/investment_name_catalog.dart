// The lists are '|'-separated: a wrapped literal must join without a space.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import '../../domain/entities/suggestion_region.dart';

/// Investment name suggestions per [SuggestionRegion] and investment category
/// id (`CategorySeed`), shown left to right in list order.
///
/// Market names, written the way that market writes them, so they are data per
/// region rather than translations. A fixed editorial list: not ranked by
/// performance and not a recommendation.
abstract final class InvestmentNameCatalog {
  /// The names for [categoryId] in [region]; empty when it has none.
  static List<String> names(SuggestionRegion region, String? categoryId) {
    final raw = _catalog[region]?[categoryId];
    return raw == null ? const [] : raw.split('|');
  }

  static const String _stock = 'inv1';
  static const String _fund = 'inv2';
  static const String _bond = 'inv3';
  static const String _deposit = 'inv4';
  static const String _gold = 'inv5';
  static const String _realEstate = 'inv6';
  static const String _crypto = 'inv7';
  static const String _business = 'inv8';

  static const Map<SuggestionRegion, Map<String, String>> _catalog = {
    SuggestionRegion.vn: {
      _stock: 'HPG|SHB|SSI|VIX|FPT|MBB|VPB|STB|TCB|VCB',
      _gold:
          'Nhẫn trơn 9999|Vàng miếng SJC|DOJI|Bảo Tín Minh Châu|Phú Quý|'
          'Vàng 24K trang sức|Vàng tích lũy|Vàng cưới|Bạc Phú Quý',
      _fund: 'E1VFVN30|FUEVFVND|DCDS|VESAF|SSI-SCA',
      _deposit:
          'Sổ VCB 12T|Sổ BIDV 12T|Sổ Agribank 12T|Sổ VietinBank 12T|'
          'Online TCB|Online MB|Online VPB|Timo|Cake|Quỹ khẩn cấp',
      _realEstate:
          'Căn hộ chung cư|Nhà phố|Đất nền|Đất vườn|Phòng trọ cho thuê|'
          'Căn hộ cho thuê|Shophouse|Đất quê|Condotel|Đất nông nghiệp',
      _crypto: 'USDT|Bitcoin|Ethereum|BNB|USDC|Solana|XRP',
      _bond: 'TP Chính phủ|TP doanh nghiệp|TP ngân hàng|Quỹ trái phiếu',
      _business:
          'Tạp hóa|Quán ăn|Quán cà phê|Shop Shopee|TikTok Shop|Xe chạy Grab|'
          'Tiệm nail/spa|Góp vốn bạn|Nhượng quyền|Startup',
    },
    SuggestionRegion.global: {
      _stock: 'AAPL|MSFT|NVDA|AMZN|GOOGL|META|TSLA|BRK.B|JPM|V',
      _gold:
          'Gold bars|Gold coins|GLD|IAU|Gold jewelry|Silver bars|'
          'Silver coins|SLV',
      _fund: 'VOO|VTI|QQQ|SPY|IVV',
      _deposit: 'High-yield savings|CD 6M|CD 12M|Money market|Emergency fund',
      _realEstate:
          'Primary home|Rental property|Condo|Multi-family|Land|'
          'Vacation home|REIT (VNQ)',
      _crypto: 'Bitcoin|Ethereum|USDC|USDT|Solana',
      _bond: 'US Treasuries|TIPS|BND|AGG|Corporate bonds|Municipal bonds',
      _business:
          'Side hustle|Online store|Amazon FBA|Uber/DoorDash|Restaurant|'
          'Franchise|Startup|Partnership',
    },
    SuggestionRegion.kr: {
      _stock: '삼성전자|SK하이닉스|현대차|네이버|카카오|LG에너지솔루션|에코프로|셀트리온|NVDA|TSLA',
      _gold: 'KRX 금시장|골드바|금통장|돌반지|순금 24K|KODEX 골드선물(H)|ACE KRX금현물|실버바',
      _fund:
          'KODEX 200|TIGER 미국S&P500|TIGER 미국나스닥100|KODEX 미국S&P500|SOL 미국배당다우존스',
      _deposit: '정기예금 12M|정기적금 12M|파킹통장|CMA|청년도약계좌|주택청약|ISA|연금저축|세이프박스|비상금',
      _realEstate: '아파트|오피스텔|빌라|전세 보증금|상가|토지|원룸 임대|분양권|재개발|지식산업센터',
      _crypto: 'BTC|XRP|ETH|USDT|SOL|DOGE',
      _bond: '국채|개인투자용 국채|미국채|회사채|국채 ETF|채권형 펀드',
      _business: '치킨집|카페|편의점|스마트스토어|쿠팡 셀러|배달 라이더|쿠팡 플렉스|프랜차이즈|동업|스타트업',
    },
    SuggestionRegion.jp: {
      _stock: 'トヨタ|三菱UFJ|ソフトバンクG|NTT|ソニーG|任天堂|三菱商事|キーエンス|日立|東京エレクトロン',
      _gold: '純金積立|金地金|金貨|金ETF(1540)|金ジュエリー|プラチナ|銀地金|銀ETF',
      _fund:
          'eMAXIS Slim 全世界株式|eMAXIS Slim 米国株式(S&P500)|SBI・V・S&P500|'
          '楽天・全米株式|ニッセイ日経225',
      _deposit: '普通預金|定期預金|ネット銀行|ゆうちょ|個人向け国債|外貨預金|新NISA|iDeCo|財形|生活防衛資金',
      _realEstate: 'マンション|戸建て|区分マンション投資|アパート経営|土地|駐車場|J-REIT|実家|別荘',
      _crypto: 'BTC|ETH|XRP|SOL|DOGE|USDC',
      _bond: '個人向け国債(変動10年)|国債|米国債|社債|債券ファンド|外債',
      _business: '副業|メルカリ|せどり|Uber Eats|飲食店|コンビニFC|民泊|YouTube|スタートアップ|共同出資',
    },
    SuggestionRegion.cn: {
      _stock: '贵州茅台|宁德时代|招商银行|中国平安|比亚迪|东方财富|腾讯控股|阿里巴巴|中国移动|工商银行',
      _gold: '积存金|实物金条|黄金ETF(518880)|周大福金饰|老凤祥金饰|纸黄金|上海金Au99.99|金币|白银',
      _fund: '沪深300ETF|中证500ETF|纳指100ETF|标普500ETF|创业板ETF',
      _deposit: '余额宝|零钱通|银行定期|大额存单|银行理财|储蓄国债|活期+|公积金|应急金',
      _realEstate: '商品房|二手房|学区房|商铺|公寓|车位|老家房产|出租房|写字楼',
      _crypto: 'BTC|ETH|USDT|USDC|BNB',
      _bond: '国债|储蓄国债|地方债|企业债|债券基金|可转债',
      _business: '淘宝店|拼多多店|抖音小店|小红书|奶茶店|餐馆|便利店|网约车|合伙|创业公司',
    },
  };
}
