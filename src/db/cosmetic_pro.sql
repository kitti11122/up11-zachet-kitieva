--
-- PostgreSQL database dump
--

\restrict dsOMFaUxuIhKLnDMNEHdQ3tAIQDvM022UResewuHJwjPWvn8ieFF3JitIpZp1Sx

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-27 19:36:12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 17611)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    name character varying(100) NOT NULL,
    parent_id integer
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17610)
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- TOC entry 234 (class 1259 OID 17695)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer,
    stock_item_id integer,
    quantity integer,
    unit_price numeric(10,2),
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price > (0)::numeric))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17694)
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- TOC entry 232 (class 1259 OID 17681)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    order_date date NOT NULL,
    user_id integer
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17680)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 228 (class 1259 OID 17638)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    category_id integer,
    subcategory_id integer,
    name character varying(200) NOT NULL,
    manufacturer character varying(100) NOT NULL,
    description text,
    composition text,
    base_price numeric(10,2),
    image_path character varying(255),
    CONSTRAINT products_base_price_check CHECK ((base_price > (0)::numeric))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17637)
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO postgres;

--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 227
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- TOC entry 220 (class 1259 OID 17582)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17581)
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_role_id_seq OWNER TO postgres;

--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- TOC entry 230 (class 1259 OID 17661)
-- Name: stock_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_items (
    stock_item_id integer NOT NULL,
    product_id integer,
    variant_id integer,
    quantity integer,
    price numeric(10,2),
    CONSTRAINT stock_items_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT stock_items_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.stock_items OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17660)
-- Name: stock_items_stock_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_items_stock_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_items_stock_item_id_seq OWNER TO postgres;

--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 229
-- Name: stock_items_stock_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_items_stock_item_id_seq OWNED BY public.stock_items.stock_item_id;


--
-- TOC entry 222 (class 1259 OID 17593)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    login character varying(50) NOT NULL,
    last_name character varying(100) NOT NULL,
    first_name character varying(100) NOT NULL,
    middle_name character varying(100),
    role_id integer
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17592)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 226 (class 1259 OID 17627)
-- Name: variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variants (
    variant_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.variants OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17626)
-- Name: variants_variant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.variants_variant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.variants_variant_id_seq OWNER TO postgres;

--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 225
-- Name: variants_variant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.variants_variant_id_seq OWNED BY public.variants.variant_id;


--
-- TOC entry 4893 (class 2604 OID 17614)
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- TOC entry 4898 (class 2604 OID 17698)
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- TOC entry 4897 (class 2604 OID 17684)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4895 (class 2604 OID 17641)
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 17585)
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- TOC entry 4896 (class 2604 OID 17664)
-- Name: stock_items stock_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items ALTER COLUMN stock_item_id SET DEFAULT nextval('public.stock_items_stock_item_id_seq'::regclass);


--
-- TOC entry 4892 (class 2604 OID 17596)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 4894 (class 2604 OID 17630)
-- Name: variants variant_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variants ALTER COLUMN variant_id SET DEFAULT nextval('public.variants_variant_id_seq'::regclass);


--
-- TOC entry 5089 (class 0 OID 17611)
-- Dependencies: 224
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (category_id, name, parent_id) FROM stdin;
1	Уход за лицом	\N
2	Уход за волосами	\N
3	Уход за телом	\N
4	Декоративная косметика	\N
5	Кремы	1
6	Шампуни	2
7	Лосьоны	3
8	Помады	4
\.


--
-- TOC entry 5099 (class 0 OID 17695)
-- Dependencies: 234
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_item_id, order_id, stock_item_id, quantity, unit_price) FROM stdin;
1	1	1	2	490.00
2	14	2	2	612.50
3	15	4	2	570.00
4	1	5	1	712.50
5	2	7	1	650.00
6	15	8	1	812.50
7	2	11	2	912.50
8	3	13	2	770.00
9	3	17	1	1056.50
10	4	19	1	970.00
11	4	23	2	1312.50
12	5	25	2	390.00
13	5	29	1	562.50
14	6	31	1	510.00
15	6	35	2	712.50
16	7	37	2	630.00
17	7	41	1	862.50
18	8	43	1	750.00
19	8	47	2	1012.50
20	9	49	2	450.00
21	9	53	1	650.00
22	10	55	1	590.00
23	10	59	2	825.00
24	11	61	2	730.00
25	11	65	1	1000.00
26	12	67	1	870.00
27	12	71	2	1175.00
28	13	73	2	590.00
29	13	77	1	850.00
30	14	79	1	770.00
\.


--
-- TOC entry 5097 (class 0 OID 17681)
-- Dependencies: 232
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, order_date, user_id) FROM stdin;
11	2026-04-24	14
10	2026-04-22	13
15	2026-05-02	18
14	2026-04-30	17
12	2026-04-26	15
4	2026-04-10	7
7	2026-04-16	10
3	2026-04-08	6
9	2026-04-20	12
6	2026-04-14	9
5	2026-04-12	8
8	2026-04-18	11
2	2026-04-06	5
13	2026-04-28	16
1	2026-04-04	4
\.


--
-- TOC entry 5093 (class 0 OID 17638)
-- Dependencies: 228
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, category_id, subcategory_id, name, manufacturer, description, composition, base_price, image_path) FROM stdin;
1	1	5	Крем базовый	Формула ухода	Крем базовый. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	490.00	IMG_10_001.png
2	1	5	Крем лёгкий	УходЛаб	Крем лёгкий. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	570.00	IMG_10_002.png
3	1	5	Крем дневной	КрасотаЛайн	Крем дневной. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	650.00	IMG_10_003.png
4	1	5	Крем вечерний	Космо	Крем вечерний. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	730.00	IMG_10_004.png
5	1	5	Крем комфорт	Формула ухода	Крем комфорт. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	810.00	IMG_10_005.png
6	1	5	Крем баланс	УходЛаб	Крем баланс. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	890.00	IMG_10_006.png
7	1	5	Крем мягкий	КрасотаЛайн	Крем мягкий. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	970.00	IMG_10_007.png
8	1	5	Крем классик	Космо	Крем классик. Категория: Уход за лицом. Тип: Кремы. Единица заказа: шт.. Доступные варианты: 30 мл, 50 мл, 75 мл.	Учебная формула: вода, глицерин, растительное масло, эмульгатор; не рецептура	1050.00	IMG_10_008.png
9	2	6	Шампунь ежедневный	Формула ухода	Шампунь ежедневный. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	390.00	IMG_10_009.png
10	2	6	Шампунь мягкий	УходЛаб	Шампунь мягкий. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	450.00	IMG_10_010.png
11	2	6	Шампунь лёгкий	КрасотаЛайн	Шампунь лёгкий. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	510.00	IMG_10_011.png
12	2	6	Шампунь баланс	Космо	Шампунь баланс. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	570.00	IMG_10_012.png
13	2	6	Шампунь свежесть	Формула ухода	Шампунь свежесть. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	630.00	IMG_10_013.png
14	2	6	Шампунь классик	УходЛаб	Шампунь классик. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	690.00	IMG_10_014.png
15	2	6	Шампунь комфорт	КрасотаЛайн	Шампунь комфорт. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	750.00	IMG_10_015.png
16	2	6	Шампунь базовый	Космо	Шампунь базовый. Категория: Уход за волосами. Тип: Шампуни. Единица заказа: шт.. Доступные варианты: 200 мл, 300 мл, 500 мл.	Учебная формула: вода, моющая основа, кондиционирующий компонент; не рецептура	810.00	IMG_10_016.png
17	3	7	Лосьон базовый	Формула ухода	Лосьон базовый. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	450.00	IMG_10_017.png
18	3	7	Лосьон лёгкий	УходЛаб	Лосьон лёгкий. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	520.00	IMG_10_018.png
19	3	7	Лосьон комфорт	КрасотаЛайн	Лосьон комфорт. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	590.00	IMG_10_019.png
20	3	7	Лосьон мягкий	Космо	Лосьон мягкий. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	660.00	IMG_10_020.png
21	3	7	Лосьон бархат	Формула ухода	Лосьон бархат. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	730.00	IMG_10_021.png
22	3	7	Лосьон свежесть	УходЛаб	Лосьон свежесть. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	800.00	IMG_10_022.png
23	3	7	Лосьон классик	КрасотаЛайн	Лосьон классик. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	870.00	IMG_10_023.png
24	3	7	Лосьон ежедневный	Космо	Лосьон ежедневный. Категория: Уход за телом. Тип: Лосьоны. Единица заказа: шт.. Доступные варианты: 100 мл, 200 мл, 300 мл.	Учебная формула: вода, глицерин, масло, эмульгатор; не рецептура	940.00	IMG_10_024.png
25	4	8	Помада матовая	Формула ухода	Помада матовая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	590.00	IMG_10_025.png
26	4	8	Помада сатиновая	УходЛаб	Помада сатиновая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	680.00	IMG_10_026.png
27	4	8	Помада кремовая	КрасотаЛайн	Помада кремовая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	770.00	IMG_10_027.png
28	4	8	Помада бархатная	Космо	Помада бархатная. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	860.00	IMG_10_028.png
29	4	8	Помада лёгкая	Формула ухода	Помада лёгкая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	950.00	IMG_10_029.png
30	4	8	Помада классическая	УходЛаб	Помада классическая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	1040.00	IMG_10_030.png
31	4	8	Помада мягкая	КрасотаЛайн	Помада мягкая. Категория: Декоративная косметика. Тип: Помады. Единица заказа: шт.. Доступные варианты: Нюдовый, Розовый, Красный.	Учебный состав: восковая основа, масла, косметические пигменты	1130.00	\N
\.


--
-- TOC entry 5085 (class 0 OID 17582)
-- Dependencies: 220
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (role_id, name) FROM stdin;
1	Администратор
2	Менеджер
3	Авторизованный пользователь
\.


--
-- TOC entry 5095 (class 0 OID 17661)
-- Dependencies: 230
-- Data for Name: stock_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_items (stock_item_id, product_id, variant_id, quantity, price) FROM stdin;
1	1	1	18	490.00
2	1	2	23	612.50
3	1	3	28	735.00
4	2	1	21	570.00
5	2	2	26	712.50
6	2	3	7	855.00
7	3	1	24	650.00
8	3	2	5	812.50
9	3	3	10	975.00
10	4	1	27	730.00
11	4	2	8	912.50
12	4	3	13	1095.00
13	5	1	6	810.00
14	5	2	11	1012.50
15	5	3	16	1215.00
16	6	1	9	890.00
17	6	2	14	1112.50
18	6	3	19	1335.00
19	7	1	12	970.00
20	7	2	17	1212.50
21	7	3	22	1455.00
22	8	1	15	1050.00
23	8	2	20	1312.50
24	8	3	25	1575.00
25	9	4	18	390.00
26	9	5	23	487.50
27	9	6	28	585.00
28	10	4	21	450.00
29	10	5	26	562.50
30	10	6	7	675.00
31	11	4	24	510.00
32	11	5	5	637.50
33	11	6	10	765.00
34	12	4	27	570.00
35	12	5	8	712.50
36	12	6	13	855.00
37	13	4	6	630.00
38	13	5	11	787.50
39	13	6	16	945.00
40	14	4	9	690.00
41	14	5	14	862.50
42	14	6	19	1035.00
43	15	4	12	750.00
44	15	5	17	937.50
45	15	6	22	1125.00
46	16	4	15	810.00
47	16	5	20	1012.50
48	16	6	25	1215.00
49	17	7	18	450.00
50	17	4	23	562.50
51	17	5	28	675.00
52	18	7	21	520.00
53	18	4	26	650.00
54	18	5	7	780.00
55	19	7	24	590.00
56	19	4	5	737.50
57	19	5	10	885.00
58	20	7	27	660.00
59	20	4	8	825.00
60	20	5	13	990.00
61	21	7	6	730.00
62	21	4	11	912.50
63	21	5	16	1095.00
64	22	7	9	800.00
65	22	4	14	1000.00
66	22	5	19	1200.00
67	23	7	12	870.00
68	23	4	17	1087.50
69	23	5	22	1305.00
70	24	7	15	940.00
71	24	4	20	1175.00
72	24	5	25	1410.00
73	25	8	18	590.00
74	25	9	23	737.50
75	25	10	28	885.00
76	26	8	21	680.00
77	26	9	26	850.00
78	26	10	7	1020.00
79	27	8	24	770.00
80	27	9	5	962.50
81	27	10	10	1155.00
82	28	8	2	860.00
83	28	9	1	1075.00
84	28	10	1	1290.00
85	29	8	1	950.00
86	29	9	1	1187.50
87	29	10	1	1425.00
88	30	8	1	1040.00
89	30	9	0	1300.00
90	30	10	1	1560.00
91	31	8	0	1130.00
92	31	9	0	1412.50
93	31	10	0	1695.00
\.


--
-- TOC entry 5087 (class 0 OID 17593)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, login, last_name, first_name, middle_name, role_id) FROM stdin;
1	admin	Иванов	Иван	Сергеевич	1
3	manager2	Смирнова	Ольга	Викторовна	2
2	manager1	Петров	Пётр	Алексеевич	2
20	client17	Белов	Алексей	Иванович	3
19	client16	Макарова	Анна	Ивановна	3
18	client15	Козлов	Алексей	Иванович	3
17	client14	Фёдорова	Анна	Ивановна	3
16	client13	Семёнов	Алексей	Иванович	3
15	client12	Павлова	Анна	Ивановна	3
14	client11	Зайцев	Алексей	Иванович	3
13	client10	Егорова	Анна	Ивановна	3
12	client09	Попов	Алексей	Иванович	3
11	client08	Лебедева	Анна	Ивановна	3
10	client07	Соколов	Алексей	Иванович	3
9	client06	Волкова	Анна	Ивановна	3
8	client05	Морозов	Алексей	Иванович	3
7	client04	Новикова	Анна	Ивановна	3
6	client03	Орлов	Алексей	Иванович	3
5	client02	Кузнецова	Анна	Ивановна	3
4	client01	Сидоров	Алексей	Иванович	3
\.


--
-- TOC entry 5091 (class 0 OID 17627)
-- Dependencies: 226
-- Data for Name: variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.variants (variant_id, name) FROM stdin;
1	30 мл
2	50 мл
3	75 мл
4	200 мл
5	300 мл
6	500 мл
7	100 мл
8	Нюдовый
9	Розовый
10	Красный
\.


--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 8, true);


--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 30, true);


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 1, false);


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 227
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_product_id_seq', 31, true);


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 3, true);


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 229
-- Name: stock_items_stock_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_items_stock_item_id_seq', 93, true);


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 20, true);


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 225
-- Name: variants_variant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.variants_variant_id_seq', 10, true);


--
-- TOC entry 4913 (class 2606 OID 17620)
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- TOC entry 4915 (class 2606 OID 17618)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4927 (class 2606 OID 17703)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- TOC entry 4925 (class 2606 OID 17688)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4921 (class 2606 OID 17649)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4905 (class 2606 OID 17591)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 4907 (class 2606 OID 17589)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- TOC entry 4923 (class 2606 OID 17669)
-- Name: stock_items stock_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_pkey PRIMARY KEY (stock_item_id);


--
-- TOC entry 4909 (class 2606 OID 17604)
-- Name: users users_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_login_key UNIQUE (login);


--
-- TOC entry 4911 (class 2606 OID 17602)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4917 (class 2606 OID 17636)
-- Name: variants variants_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_name_key UNIQUE (name);


--
-- TOC entry 4919 (class 2606 OID 17634)
-- Name: variants variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (variant_id);


--
-- TOC entry 4929 (class 2606 OID 17621)
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(category_id);


--
-- TOC entry 4935 (class 2606 OID 17704)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- TOC entry 4936 (class 2606 OID 17709)
-- Name: order_items order_items_stock_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_stock_item_id_fkey FOREIGN KEY (stock_item_id) REFERENCES public.stock_items(stock_item_id);


--
-- TOC entry 4934 (class 2606 OID 17689)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 4930 (class 2606 OID 17650)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- TOC entry 4931 (class 2606 OID 17655)
-- Name: products products_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.categories(category_id);


--
-- TOC entry 4932 (class 2606 OID 17670)
-- Name: stock_items stock_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- TOC entry 4933 (class 2606 OID 17675)
-- Name: stock_items stock_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_items
    ADD CONSTRAINT stock_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.variants(variant_id);


--
-- TOC entry 4928 (class 2606 OID 17605)
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id);


-- Completed on 2026-10-27 19:36:12

--
-- PostgreSQL database dump complete
--

\unrestrict dsOMFaUxuIhKLnDMNEHdQ3tAIQDvM022UResewuHJwjPWvn8ieFF3JitIpZp1Sx

