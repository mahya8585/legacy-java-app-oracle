# システム概要 — Ocean Dive Tours

## 1. システム概要

Ocean Dive Tours は、ダイビングツアーの予約管理を行うWebアプリケーションです。
顧客向けのツアー検索・予約・ダイビングログ管理と、管理者向けのツアー管理・予約管理・レポート機能を提供します。

**意図的にレガシーアーキテクチャ**で構築されており、モダナイゼーション演習やマイグレーション評価の素材として設計されています。

---

## 2. 技術スタック

| レイヤー | 技術 | バージョン |
|---|---|---|
| 言語 | Java | 1.8 |
| フレームワーク | Spring Boot | 2.7.18 |
| テンプレートエンジン | Thymeleaf + Layout Dialect | 3.1.0 |
| セキュリティ | Spring Security | 5.x |
| データアクセス | Spring JDBC（JPA/Hibernate 不使用） | — |
| データベース | Oracle 19c XE (PDB: XEPDB1) | 19c |
| JDBCドライバ | ojdbc8 | — |
| バリデーション | Bean Validation (JSR 380) | — |
| ビルドツール | Maven | 3.8+ |
| コンテナ | Docker + Docker Compose | — |

---

## 3. アーキテクチャ

### 3.1 全体構成

```
┌──────────┐     ┌──────────────────────┐     ┌─────────────────┐     ┌───────────────┐
│ ブラウザ  │────▶│ Spring MVC Controller │────▶│  Service Layer  │────▶│   DAO Layer   │
│          │◀────│   (Thymeleaf SSR)     │◀────│  (thin delegate)│◀────│ (SimpleJdbcCall)│
└──────────┘     └──────────────────────┘     └─────────────────┘     └───────┬───────┘
                                                                              │
                                                                     SimpleJdbcCall
                                                                              │
                                                                     ┌────────▼────────┐
                                                                     │  Oracle PL/SQL   │
                                                                     │  パッケージ (8個) │
                                                                     └────────┬────────┘
                                                                              │
                                                                     ┌────────▼────────┐
                                                                     │  Oracle 19c XE   │
                                                                     │  (13テーブル)     │
                                                                     └─────────────────┘
```

### 3.2 アーキテクチャ方針

| 方針 | 説明 |
|---|---|
| ORM不使用 | JPA/Hibernateを用いず、全DB操作をPL/SQLストアドプロシージャ経由で実行 |
| ビジネスロジックはDB側に集中 | Java側のService層はDAO呼び出しのデリゲーションのみ |
| SYS_REFCURSORパターン | PL/SQLからカーソルを返し、Java側でRowMapperによりDTOにマッピング |
| サーバーサイドレンダリング | SPA/REST APIではなくThymeleafによるMVCパターン |
| セッションベース認証 | Spring Security 5 + カスタムAuthenticationProvider |
| パスワードハッシュはDB側 | DBMS_CRYPTO SHA-256（PL/SQL側でハッシュ処理） |
| 楽観ロック | TOUR_SCHEDULES.VERSION列で予約時の残席管理 |

---

## 4. 機能一覧

### 4.1 公開画面（認証不要）

| 機能 | URL | 説明 |
|---|---|---|
| トップページ | `/` | おすすめツアー + 最新ニュース表示 |
| ツアー一覧 | `/tours` | 検索・絞り込み（キーワード、エリア、難易度、日数、日付、価格）＋ページング |
| ツアー詳細 | `/tours/{id}` | ツアー情報、関連ダイブサイト、インストラクター、スケジュール |
| ダイブサイト一覧 | `/divesites` | エリア・難易度フィルタ |
| ダイブサイト詳細 | `/divesites/{id}` | サイト情報 + 関連ツアー |
| インストラクター一覧 | `/instructors` | 全インストラクター表示 |
| インストラクター詳細 | `/instructors/{id}` | プロフィール + 担当ツアー |
| 会員登録 | `/customer/register` | 新規顧客登録フォーム |
| ログイン | `/customer/login` | メール＋パスワード認証 |

### 4.2 顧客画面（ROLE_CUSTOMER 必須）

| 機能 | URL | 説明 |
|---|---|---|
| マイページ | `/customer/mypage` | 会員情報 + 予約一覧 |
| プロフィール編集 | `/customer/profile` | 氏名、電話番号、ライセンス等の変更 |
| 予約作成 | `/reservations/new` | ツアースケジュール選択 + オプション追加 |
| 予約完了 | `/reservations/complete` | 予約完了確認画面 |
| 予約詳細 | `/reservations/{id}` | 予約内容確認（本人チェック有り） |
| 予約キャンセル | `POST /reservations/{id}/cancel` | キャンセル処理（返金額自動計算） |
| ダイビングログ一覧 | `/divinglogs` | 自分のダイビングログ（ページング） |
| ダイビングログ記録 | `/divinglogs/new` | 新規ダイビングログ入力 |

### 4.3 管理画面（ROLE_ADMIN 必須）

| 機能 | URL | 説明 |
|---|---|---|
| ダッシュボード | `/admin` | 月別売上サマリー |
| ツアー管理 | `/admin/tours` | ツアー一覧・新規作成・編集・論理削除 |
| 予約管理 | `/admin/reservations` | 全予約一覧（ステータス・日付フィルタ） |
| 顧客管理 | `/admin/customers` | 顧客一覧（検索・ページング） |
| レポート | `/admin/reports` | 月次売上・ツアー人気ランキング・稼働率 |

---

## 5. データベース設計

### 5.1 ER図（概要）

```
                          ┌──────────────┐
                          │  CUSTOMERS   │
                          └──────┬───────┘
                                 │ 1
                    ┌────────────┼────────────┐
                    │            │            │
                    ▼ *          ▼ *          ▼ *
           ┌──────────────┐ ┌──────────┐ ┌──────────────┐
           │ RESERVATIONS │ │DIVING_LOGS│ │              │
           └──────┬───────┘ └──────────┘ │              │
                  │ 1                     │              │
                  ▼ *                     │              │
        ┌───────────────────┐             │              │
        │RESERVATION_OPTIONS│             │              │
        └────────┬──────────┘             │              │
                 │ *                      │              │
                 ▼ 1                      │              │
        ┌──────────────┐                  │              │
        │OPTIONS_MASTER│                  │              │
        └──────────────┘                  │              │
                                          │              │
        ┌──────────────┐                  │              │
        │    TOURS     │──────────────────┘              │
        └──┬───┬───┬───┘                                 │
           │   │   │                                     │
           │   │   └──────────┐                          │
           │   │              ▼ *                        │
           │   │    ┌─────────────────┐   ┌────────────┐│
           │   │    │ TOUR_SCHEDULES  │──▶│RESERVATIONS││
           │   │    └─────────────────┘   └────────────┘│
           │   │                                         │
           │   ▼ *                                       │
           │  ┌─────────────────┐  ┌──────────────┐     │
           │  │ TOUR_DIVE_SITES │─▶│  DIVE_SITES  │◀────┘
           │  └─────────────────┘  └──────────────┘
           │
           ▼ *
    ┌──────────────────┐   ┌──────────────┐
    │ TOUR_INSTRUCTORS │──▶│ INSTRUCTORS  │
    └──────────────────┘   └──────────────┘

    ┌──────────┐  ┌──────────────┐
    │   NEWS   │  │ ADMIN_USERS  │
    └──────────┘  └──────────────┘
```

### 5.2 テーブル一覧（13テーブル）

| テーブル | 主キー | 説明 | 外部キー |
|---|---|---|---|
| **CUSTOMERS** | CUSTOMER_ID | 顧客マスタ。EMAIL、PASSWORD_HASH(RAW)、氏名、電話、ライセンスレベル、ダイブ本数等 | — |
| **TOURS** | TOUR_ID | ツアーマスタ。ツアー名、DESCRIPTION(CLOB)、エリア、難易度、定員、価格、日数等 | — |
| **TOUR_SCHEDULES** | SCHEDULE_ID | ツアー日程。日付、開始時間、残席数、VERSION(楽観ロック) | FK → TOURS |
| **DIVE_SITES** | SITE_ID | ダイブサイトマスタ。サイト名、DESCRIPTION(CLOB)、最大水深、水温、難易度等 | — |
| **TOUR_DIVE_SITES** | (TOUR_ID, SITE_ID) | ツアー⇔ダイブサイト中間テーブル。DIVE_ORDER | FK → TOURS, DIVE_SITES |
| **INSTRUCTORS** | INSTRUCTOR_ID | インストラクターマスタ。氏名、資格、経験年数、専門分野、PROFILE(CLOB) | — |
| **TOUR_INSTRUCTORS** | (TOUR_ID, INSTRUCTOR_ID) | ツアー⇔インストラクター中間テーブル。ROLE | FK → TOURS, INSTRUCTORS |
| **OPTIONS_MASTER** | OPTION_ID | オプションマスタ。レンタル・送迎・撮影・保険等のカテゴリ別オプション | — |
| **RESERVATIONS** | RESERVATION_ID | 予約。顧客、スケジュール、参加人数、合計金額、ステータス、キャンセル理由、返金額 | FK → CUSTOMERS, TOUR_SCHEDULES |
| **RESERVATION_OPTIONS** | RES_OPTION_ID | 予約オプション明細。オプション選択と小計 | FK → RESERVATIONS, OPTIONS_MASTER |
| **DIVING_LOGS** | LOG_ID | ダイビングログ。ダイブ日、最大深度、潜水時間、水温、透明度、天候、バディ等 | FK → CUSTOMERS, DIVE_SITES, RESERVATIONS |
| **NEWS** | NEWS_ID | ニュース。タイトル、CONTENT(CLOB)、カテゴリ、公開日、ステータス | — |
| **ADMIN_USERS** | ADMIN_ID | 管理者ユーザー。ユーザー名、PASSWORD_HASH(RAW)、表示名、役割 | — |

### 5.3 シーケンス（11個）

各テーブルの主キー採番用: `SEQ_CUSTOMERS`, `SEQ_TOURS`, `SEQ_TOUR_SCHEDULES`, `SEQ_DIVE_SITES`, `SEQ_INSTRUCTORS`, `SEQ_OPTIONS_MASTER`, `SEQ_RESERVATIONS`, `SEQ_RES_OPTIONS`, `SEQ_DIVING_LOGS`, `SEQ_NEWS`, `SEQ_ADMIN_USERS`

---

## 6. PL/SQLパッケージ

### 6.1 パッケージ一覧（8パッケージ）

| パッケージ | 関連テーブル | 機能概要 |
|---|---|---|
| **PKG_CUSTOMER** | CUSTOMERS | 認証（SHA-256）、会員登録、プロフィール更新、情報取得、一覧検索 |
| **PKG_TOUR** | TOURS, TOUR_SCHEDULES | ツアー検索（動的WHERE+ページング）、詳細取得（4カーソル返却）、おすすめ、保存、削除 |
| **PKG_RESERVATION** | RESERVATIONS, RESERVATION_OPTIONS, TOUR_SCHEDULES | 予約作成（楽観ロック+残席管理）、キャンセル（返金額自動計算）、詳細、一覧、料金計算 |
| **PKG_DIVE_SITE** | DIVE_SITES | ダイブサイト一覧（エリア/難易度フィルタ）、詳細+関連ツアー |
| **PKG_INSTRUCTOR** | INSTRUCTORS | インストラクター一覧、詳細+担当ツアー |
| **PKG_DIVING_LOG** | DIVING_LOGS | ダイビングログ一覧（ページング）、保存 |
| **PKG_NEWS** | NEWS | 最新ニュース取得、保存 |
| **PKG_REPORT** | RESERVATIONS, TOUR_SCHEDULES, TOURS | 月次売上集計、ツアー人気ランキング（RANK）、稼働率 |

### 6.2 プロシージャ詳細

#### PKG_CUSTOMER

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| AUTHENTICATE | IN: p_email, p_password / OUT: o_customer_id, o_result_code, o_result_msg | DBMS_CRYPTO SHA-256によるパスワード認証 |
| REGISTER_CUSTOMER | IN: p_email, p_password, 氏名, 電話, 生年月日, ライセンスレベル / OUT: o_customer_id, o_result_code, o_result_msg | メール重複チェック付き会員登録 |
| UPDATE_PROFILE | IN: p_customer_id, 各プロフィール項目 / OUT: o_result_code, o_result_msg | プロフィール更新 |
| GET_CUSTOMER_INFO | IN: p_customer_id / OUT: o_customer (SYS_REFCURSOR) | 顧客情報取得 |
| GET_ALL_CUSTOMERS | IN: p_keyword, p_status, p_page, p_page_size / OUT: o_customers (SYS_REFCURSOR), o_total_count | 管理者用顧客検索 |

#### PKG_TOUR

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| SEARCH_TOURS | IN: p_area, p_difficulty, p_date_from/to, p_price_min/max, p_duration_days, p_keyword, p_page, p_page_size / OUT: o_tours (SYS_REFCURSOR), o_total_count | 動的WHERE構築＋ページネーション。エリアはLIKE部分一致 |
| GET_TOUR_DETAIL | IN: p_tour_id / OUT: o_tour, o_sites, o_instructors, o_schedules (各SYS_REFCURSOR) | 4カーソルで詳細＋関連データ一括取得 |
| GET_FEATURED_TOURS | IN: p_limit / OUT: o_tours (SYS_REFCURSOR) | おすすめツアー取得 |
| SAVE_TOUR | IN: p_tour_id(IN OUT), ツアー各項目 / OUT: o_result_code, o_result_msg | 登録/更新（必須バリデーション付き） |
| DELETE_TOUR | IN: p_tour_id / OUT: o_result_code, o_result_msg | 論理削除（STATUS='DELETED'） |

#### PKG_RESERVATION

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| CREATE_RESERVATION | IN: p_customer_id, p_schedule_id, p_num_participants, p_option_ids(CSV), p_option_quantities(CSV), p_notes / OUT: o_reservation_id, o_total_price, o_result_code, o_result_msg | 楽観ロック＋残席チェック＋自動料金計算 |
| CANCEL_RESERVATION | IN: p_reservation_id, p_customer_id, p_cancel_reason / OUT: o_refund_amount, o_result_code, o_result_msg | キャンセル＋返金額自動計算＋残席復元 |
| GET_RESERVATION_DETAIL | IN: p_reservation_id / OUT: o_reservation, o_options (各SYS_REFCURSOR) | 予約詳細＋オプション一覧 |
| GET_CUSTOMER_RESERVATIONS | IN: p_customer_id, p_status / OUT: o_reservations (SYS_REFCURSOR) | 顧客別予約一覧 |
| CALC_TOTAL_PRICE | IN: p_schedule_id, p_num_participants, p_option_ids, p_option_quantities / RETURN: NUMBER | 料金計算ファンクション |
| GET_ALL_RESERVATIONS | IN: p_status, p_date_from/to, p_page, p_page_size / OUT: o_reservations (SYS_REFCURSOR), o_total_count | 管理者用全予約一覧 |

#### PKG_DIVE_SITE

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| GET_DIVE_SITES | IN: p_area, p_difficulty / OUT: o_sites (SYS_REFCURSOR) | エリア・難易度フィルタ付き一覧 |
| GET_DIVE_SITE_DETAIL | IN: p_site_id / OUT: o_site, o_related_tours (各SYS_REFCURSOR) | 詳細＋関連ツアー |

#### PKG_INSTRUCTOR

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| GET_INSTRUCTORS | OUT: o_instructors (SYS_REFCURSOR) | 全インストラクター一覧 |
| GET_INSTRUCTOR_DETAIL | IN: p_instructor_id / OUT: o_instructor, o_tours (各SYS_REFCURSOR) | 詳細＋担当ツアー |

#### PKG_DIVING_LOG

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| GET_CUSTOMER_LOGS | IN: p_customer_id, p_page, p_page_size / OUT: o_logs (SYS_REFCURSOR), o_total_count | ページング付きログ一覧 |
| SAVE_DIVING_LOG | IN: p_log_id(IN OUT), ログ各項目 / OUT: o_result_code, o_result_msg | ログ記録（登録/更新） |

#### PKG_NEWS

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| GET_LATEST_NEWS | IN: p_limit, p_category / OUT: o_news (SYS_REFCURSOR) | 最新ニュース取得 |
| SAVE_NEWS | IN: p_news_id(IN OUT), ニュース各項目 / OUT: o_result_code, o_result_msg | ニュース保存 |

#### PKG_REPORT

| プロシージャ | パラメータ | 説明 |
|---|---|---|
| GET_MONTHLY_SALES | IN: p_year, p_month / OUT: o_report (SYS_REFCURSOR) | 月次売上集計 |
| GET_TOUR_POPULARITY | IN: p_date_from, p_date_to, p_limit / OUT: o_report (SYS_REFCURSOR) | ツアー人気RANKランキング |
| GET_OCCUPANCY_RATE | IN: p_year, p_month / OUT: o_report (SYS_REFCURSOR) | ツアースケジュール稼働率 |

---

## 7. アプリケーション層

### 7.1 コントローラー（10クラス）

#### 公開コントローラー

| クラス | エンドポイント | 説明 |
|---|---|---|
| **HomeController** | `GET /` | トップページ（おすすめツアー＋最新ニュース） |
| **TourController** | `GET /tours`, `GET /tours/{id}` | ツアー一覧（検索・ページング）、詳細 |
| **DiveSiteController** | `GET /divesites`, `GET /divesites/{id}` | ダイブサイト一覧・詳細 |
| **InstructorController** | `GET /instructors`, `GET /instructors/{id}` | インストラクター一覧・詳細 |
| **CustomerController** | `GET/POST /customer/*` | ログイン、登録、マイページ、プロフィール |
| **ReservationController** | `GET/POST /reservations/*` | 予約作成・詳細・キャンセル |
| **DivingLogController** | `GET/POST /divinglogs/*` | ダイビングログ一覧・記録 |

#### 管理コントローラー

| クラス | エンドポイント | 説明 |
|---|---|---|
| **AdminDashboardController** | `GET /admin`, `/admin/dashboard` | 管理ダッシュボード |
| **AdminTourController** | `GET/POST /admin/tours/*` | ツアーCRUD |
| **AdminReservationController** | `GET /admin/reservations` | 予約管理一覧 |
| **AdminCustomerController** | `GET /admin/customers` | 顧客管理一覧 |
| **AdminReportController** | `GET /admin/reports` | レポート表示 |

#### 例外ハンドリング

| クラス | 説明 |
|---|---|
| **GlobalExceptionHandler** | `@ControllerAdvice`。DataAccessExceptionからORA-20xxxビジネスエラーを抽出して表示 |

### 7.2 サービス層（8クラス）

全サービスはクラスレベルで `@Transactional(readOnly = true)` を宣言し、書き込みメソッドのみ `@Transactional` でオーバーライド。DAO呼び出しのデリゲーションパターン。

| サービス | メソッド |
|---|---|
| **CustomerService** | registerCustomer, updateProfile, getCustomerInfo, getAllCustomers |
| **TourService** | searchTours, getTourDetail, getFeaturedTours, saveTour, deleteTour |
| **ReservationService** | createReservation, cancelReservation, getReservationDetail, getCustomerReservations, calcTotalPrice, getAllReservations |
| **DiveSiteService** | getDiveSites, getDiveSiteDetail |
| **InstructorService** | getInstructors, getInstructorDetail |
| **DivingLogService** | getCustomerLogs, saveDivingLog |
| **NewsService** | getLatestNews, saveNews |
| **ReportService** | getMonthlySales, getTourPopularity, getOccupancyRate |

### 7.3 DAO層（9クラス）

8/9クラスが `SimpleJdbcCall` + `OracleTypes.CURSOR` でPL/SQLストアドプロシージャを呼び出し。唯一 `OptionMasterDao` のみ `JdbcTemplate` で直接SQLを発行。

| DAO | PL/SQLパッケージ | RowMapper |
|---|---|---|
| **CustomerDao** | PKG_CUSTOMER | CUSTOMER_ROW_MAPPER |
| **TourDao** | PKG_TOUR | TOUR_ROW_MAPPER, SITE_ROW_MAPPER, INSTRUCTOR_ROW_MAPPER, SCHEDULE_ROW_MAPPER |
| **ReservationDao** | PKG_RESERVATION | RESERVATION_ROW_MAPPER, OPTION_ROW_MAPPER |
| **DiveSiteDao** | PKG_DIVE_SITE | SITE_ROW_MAPPER, TOUR_ROW_MAPPER |
| **InstructorDao** | PKG_INSTRUCTOR | INSTRUCTOR_ROW_MAPPER, TOUR_ROW_MAPPER |
| **DivingLogDao** | PKG_DIVING_LOG | LOG_ROW_MAPPER |
| **NewsDao** | PKG_NEWS | NEWS_ROW_MAPPER |
| **ReportDao** | PKG_REPORT | REPORT_ROW_MAPPER |
| **OptionMasterDao** | —（直接SQL） | OPTION_ROW_MAPPER |

### 7.4 DTO・Formクラス

#### DTO（12クラス）

| クラス | 説明 |
|---|---|
| CustomerDto | 顧客情報（ID、メール、氏名、電話、ライセンス等） |
| TourDto | ツアー情報（基本情報＋検索結果用nearestDate/remainingSeats＋詳細用関連リスト） |
| TourScheduleDto | ツアースケジュール（日程、残席、ステータス） |
| TourSearchCondition | 検索条件（キーワード、エリア、難易度、日数、日付範囲、価格範囲、ページング） |
| DiveSiteDto | ダイブサイト情報（サイト名、水深、水温、難易度等） |
| InstructorDto | インストラクター情報（氏名、資格、経験年数、専門分野等） |
| ReservationDto | 予約情報（予約ID、参加人数、合計金額、ステータス＋JOIN情報） |
| ReservationOptionDto | 予約オプション明細 |
| OptionMasterDto | オプションマスタ（名称、カテゴリ、単価） |
| DivingLogDto | ダイビングログ（深度、時間、水温、透明度等） |
| NewsDto | ニュース（タイトル、本文、カテゴリ、公開日） |
| ReportDto | レポート汎用（売上、予約数、稼働率等） |

#### Form（4クラス）— Bean Validationアノテーション付き

| クラス | バリデーション |
|---|---|
| LoginForm | email(@NotBlank @Email), password(@NotBlank) |
| CustomerRegistrationForm | email(@Email), password(@Size(min=6,max=100)), passwordConfirm, 氏名(@NotBlank) |
| ReservationForm | scheduleId(@NotNull), numParticipants(@Min(1)), optionIds, notes |
| TourForm | tourName(@NotBlank), area(@NotBlank), difficulty(@NotBlank), maxParticipants(@Min(1)), basePrice(@Min(0)), durationDays(@Min(1)) |

---

## 8. セキュリティ

### 8.1 認証フロー

```
ログインフォーム (POST /customer/login)
    ↓
CustomAuthenticationProvider
    ↓
CustomerDao.authenticate()
    ↓
SimpleJdbcCall → PKG_CUSTOMER.AUTHENTICATE
    ↓
DBMS_CRYPTO SHA-256 によるパスワード照合
    ↓
CustomUserDetails (userId, email, ROLE_CUSTOMER) を返却
    ↓
SecurityContextHolder に格納 → セッション管理
```

### 8.2 アクセス制御

| URLパターン | 権限 |
|---|---|
| `/`, `/tours/**`, `/divesites/**`, `/instructors/**`, `/news/**` | 公開（認証不要） |
| `/css/**`, `/js/**`, `/images/**` | 静的リソース（公開） |
| `/customer/register`, `/customer/login` | 公開 |
| `/customer/**`, `/reservations/**`, `/divinglogs/**` | **ROLE_CUSTOMER** 必須 |
| `/admin/**` | **ROLE_ADMIN** 必須 |

### 8.3 セキュリティ設定

| 項目 | 設定 |
|---|---|
| CSRF | 有効（デフォルト） |
| セッションタイムアウト | 30分 |
| frameOptions | sameOrigin |
| ログイン成功リダイレクト | `/customer/mypage` |
| ログアウトリダイレクト | `/` |

---

## 9. インフラストラクチャ

### 9.1 Docker構成

```
docker-compose.yml
├── oracle-db サービス
│   ├── イメージ: gvenzl/oracle-xe:19-slim ベース
│   ├── ポート: 1521:1521
│   ├── ヘルスチェック: sqlplus (start_period: 120s)
│   ├── Volume: db/migration, db/packages, db/seed → 読み取り専用マウント
│   └── init-scripts/01_create_user.sql → DIVINGAPPユーザー作成
│
└── app サービス
    ├── イメージ: マルチステージビルド
    │   ├── Stage 1: maven:3.8-openjdk-8 (ビルド)
    │   └── Stage 2: openjdk:8-jre-slim (実行)
    ├── ポート: 8080:8080
    ├── 環境変数: SPRING_PROFILES_ACTIVE=docker
    └── 依存: oracle-db の healthy 状態待ち
```

### 9.2 接続情報

| 項目 | 値 |
|---|---|
| DBホスト（Docker内） | oracle-db:1521/XEPDB1 |
| DBホスト（ローカル開発） | localhost:1521/XEPDB1 |
| DBスキーマユーザー | DIVINGAPP / divingapp123 |
| アプリケーションポート | 8080 |
| コネクションプール | HikariCP (max=10, min-idle=2, timeout=30s) |

---

## 10. 画面テンプレート構成

Thymeleaf Layout Dialect による共通レイアウト方式。全26テンプレート。

```
templates/
├── layout/
│   └── default.html          # 共通レイアウト（head, header, footer, content placeholder）
├── fragments/
│   ├── header.html            # ナビゲーションヘッダー
│   └── footer.html            # フッター
├── error/
│   └── general.html           # エラー画面
├── home.html                  # トップページ
├── tour/
│   ├── list.html              # ツアー一覧（検索フォーム＋カードグリッド＋ページング）
│   └── detail.html            # ツアー詳細
├── divesite/
│   ├── list.html              # ダイブサイト一覧
│   └── detail.html            # ダイブサイト詳細
├── instructor/
│   ├── list.html              # インストラクター一覧
│   └── detail.html            # インストラクター詳細
├── customer/
│   ├── login.html             # ログインフォーム
│   ├── register.html          # 新規登録フォーム
│   ├── mypage.html            # マイページ
│   └── profile.html           # プロフィール編集
├── reservation/
│   ├── form.html              # 予約フォーム
│   ├── detail.html            # 予約詳細
│   └── complete.html          # 予約完了
├── divinglog/
│   ├── list.html              # ダイビングログ一覧
│   └── form.html              # ダイビングログ記録
└── admin/
    ├── dashboard.html          # 管理ダッシュボード
    ├── customer/
    │   └── list.html           # 顧客管理
    ├── tour/
    │   ├── list.html           # ツアー管理
    │   └── form.html           # ツアー新規/編集
    ├── reservation/
    │   └── list.html           # 予約管理
    └── report/
        └── index.html          # レポート
```

### 静的リソース

| ファイル | 説明 |
|---|---|
| `static/css/style.css` | フルカスタムCSS。CSS変数ベース（--primary: #0077b6）。日本語フォント対応。レスポンシブ |
| `static/js/app.js` | モバイルナビトグル、確認ダイアログ、通貨フォーマット（¥）、アラート自動非表示 |

---

## 11. サンプルデータ

`db/seed/sample_data.sql` に以下のサンプルデータを収録:

| データ | 件数 | 備考 |
|---|---|---|
| ダイブサイト | 30件 | 沖縄、伊豆、屋久島、宮古島、石垣島、和歌山、小笠原、高知、奄美大島等 |
| インストラクター | 10名 | 各専門分野・資格 |
| ツアー | 20件 | 日帰り〜5日間、初心者〜上級者 |
| ツアースケジュール | 50件 | 各ツアーの開催日程 |
| ニュース | 10件 | 各カテゴリ |
| 顧客 | 10名 | テストアカウント含む |

### テストアカウント

| 種別 | メールアドレス | パスワード |
|---|---|---|
| 顧客 | tanaka@example.com | test1234 |
| 顧客 | suzuki@example.com | test1234 |

---

## 12. ディレクトリ構成

```
legacy-java-app-oracle/
├── .env.example                    # 環境変数テンプレート
├── docker-compose.yml              # Docker Compose定義
├── Dockerfile                      # アプリケーションイメージ（マルチステージ）
├── pom.xml                         # Maven設定
├── README.md                       # プロジェクト概要
│
├── docker/
│   └── oracle/
│       ├── Dockerfile              # Oracle 19c XEイメージ
│       └── init-scripts/
│           └── 01_create_user.sql  # DBスキーマユーザー作成
│
├── db/
│   ├── migration/                  # DDL・初期データ
│   │   ├── V001__create_tables.sql #   テーブル・シーケンス・インデックス
│   │   ├── V002__create_packages.sql#  PL/SQLパッケージ生成
│   │   └── V003__insert_master_data.sql# マスタデータ
│   ├── packages/                   # PL/SQLパッケージソース（8パッケージ×spec/body）
│   │   ├── pkg_customer_spec.sql
│   │   ├── pkg_customer_body.sql
│   │   ├── pkg_tour_spec.sql
│   │   ├── pkg_tour_body.sql
│   │   ├── pkg_reservation_spec.sql
│   │   ├── pkg_reservation_body.sql
│   │   ├── pkg_dive_site_spec.sql
│   │   ├── pkg_dive_site_body.sql
│   │   ├── pkg_instructor_spec.sql
│   │   ├── pkg_instructor_body.sql
│   │   ├── pkg_diving_log_spec.sql
│   │   ├── pkg_diving_log_body.sql
│   │   ├── pkg_news_spec.sql
│   │   ├── pkg_news_body.sql
│   │   ├── pkg_report_spec.sql
│   │   └── pkg_report_body.sql
│   └── seed/
│       └── sample_data.sql         # サンプルデータ（30サイト, 20ツアー, 10顧客等）
│
├── docs/
│   ├── development-setup.md        # 開発環境セットアップ手順
│   └── system-overview.md          # 本ドキュメント
│
└── src/main/
    ├── java/com/divingapp/
    │   ├── DivingAppApplication.java   # Spring Bootエントリポイント
    │   ├── config/
    │   │   ├── DataSourceConfig.java   #   DataSource設定
    │   │   ├── WebSecurityConfig.java  #   Spring Security設定
    │   │   ├── CustomAuthenticationProvider.java  # PL/SQL認証プロバイダ
    │   │   └── CustomUserDetails.java  #   ユーザー詳細情報
    │   ├── controller/                 # 公開・顧客画面コントローラ（7クラス＋例外ハンドラ）
    │   │   └── admin/                  #   管理画面コントローラ（5クラス）
    │   ├── dao/                        # DAOクラス（9クラス）
    │   ├── dto/                        # DTOクラス（12クラス）
    │   ├── form/                       # フォームクラス（4クラス）
    │   └── service/                    # サービスクラス（8クラス）
    └── resources/
        ├── application.yml             # アプリケーション設定
        ├── messages.properties         # メッセージ定義
        ├── templates/                  # Thymeleafテンプレート（26ファイル）
        ├── static/css/style.css        # カスタムCSS
        └── static/js/app.js           # JavaScript
```
