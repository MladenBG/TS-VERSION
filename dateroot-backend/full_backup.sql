--
-- PostgreSQL database dump
--

\restrict FCrFrEoAHbJTg9UbtVMwE5yrIg4pnjKb7b96F8Mu1rsogaOqGy0UnNODEt4CqJr

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

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

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: banned_ips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.banned_ips (
    ip character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.banned_ips OWNER TO postgres;

--
-- Name: blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    blocker_id uuid,
    blocked_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.blocks OWNER TO postgres;

--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friends (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    friend_id uuid,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.friends OWNER TO postgres;

--
-- Name: gallery_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gallery_images (
    id integer NOT NULL,
    user_id uuid,
    image_url text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.gallery_images OWNER TO postgres;

--
-- Name: gallery_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gallery_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gallery_images_id_seq OWNER TO postgres;

--
-- Name: gallery_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gallery_images_id_seq OWNED BY public.gallery_images.id;


--
-- Name: gifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gifts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    gift_name character varying(50) NOT NULL,
    coins_cost integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.gifts OWNER TO postgres;

--
-- Name: likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.likes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    liked_user_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.likes OWNER TO postgres;

--
-- Name: lobby_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lobby_messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lobby_messages OWNER TO postgres;

--
-- Name: private_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.private_messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.private_messages OWNER TO postgres;

--
-- Name: profile_views; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_views (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    viewer_id uuid,
    viewed_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.profile_views OWNER TO postgres;

--
-- Name: reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    reporter_id uuid,
    reported_id uuid,
    reason text NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reports OWNER TO postgres;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    plan_name character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    starts_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ends_at timestamp without time zone NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: user_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_blocks (
    id integer NOT NULL,
    blocker_id character varying(255) NOT NULL,
    blocked_id character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_blocks OWNER TO postgres;

--
-- Name: user_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_blocks_id_seq OWNER TO postgres;

--
-- Name: user_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_blocks_id_seq OWNED BY public.user_blocks.id;


--
-- Name: user_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_reports (
    id integer NOT NULL,
    reporter_id character varying(255) NOT NULL,
    reported_id character varying(255) NOT NULL,
    reason text NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_reports OWNER TO postgres;

--
-- Name: user_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_reports_id_seq OWNER TO postgres;

--
-- Name: user_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_reports_id_seq OWNED BY public.user_reports.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    internal_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    gender character varying(20),
    age integer,
    city character varying(100),
    image text,
    is_vip boolean DEFAULT false,
    role character varying(20) DEFAULT 'user'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    eye_color character varying(50),
    hair_color character varying(50),
    height character varying(20),
    sexuality character varying(50),
    bio text,
    is_invisible boolean DEFAULT false,
    name character varying(100) NOT NULL,
    is_banned boolean DEFAULT false,
    last_ip character varying(255),
    latitude numeric(10,8),
    longitude numeric(11,8)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_internal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_internal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_internal_id_seq OWNER TO postgres;

--
-- Name: users_internal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_internal_id_seq OWNED BY public.users.internal_id;


--
-- Name: video_calls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_calls (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    caller_id uuid,
    receiver_id uuid,
    status character varying(20) DEFAULT 'missed'::character varying,
    duration_seconds integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.video_calls OWNER TO postgres;

--
-- Name: gallery_images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_images ALTER COLUMN id SET DEFAULT nextval('public.gallery_images_id_seq'::regclass);


--
-- Name: user_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks ALTER COLUMN id SET DEFAULT nextval('public.user_blocks_id_seq'::regclass);


--
-- Name: user_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_reports ALTER COLUMN id SET DEFAULT nextval('public.user_reports_id_seq'::regclass);


--
-- Name: users internal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN internal_id SET DEFAULT nextval('public.users_internal_id_seq'::regclass);


--
-- Data for Name: banned_ips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.banned_ips (ip, created_at) FROM stdin;
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocks (id, blocker_id, blocked_id, created_at) FROM stdin;
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friends (id, user_id, friend_id, status, created_at) FROM stdin;
f6cf0502-adf5-4e05-92b7-3de1fee84676	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	pending	2026-03-10 13:52:14.589989
f032cd6b-2a22-4434-bd37-16ee59ab6005	3a499dce-e3dd-46e9-96e2-e3db846599ca	632d4554-5c84-47bc-b7a9-c2b74a8cb859	pending	2026-03-10 16:24:02.54293
\.


--
-- Data for Name: gallery_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gallery_images (id, user_id, image_url, created_at) FROM stdin;
\.


--
-- Data for Name: gifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gifts (id, sender_id, receiver_id, gift_name, coins_cost, created_at) FROM stdin;
65697337-a04a-41df-b992-9fc9b8306123	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	🌹	0	2026-03-10 13:52:07.696496
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.likes (id, user_id, liked_user_id, created_at) FROM stdin;
aa3ebd5e-665f-46a4-8ce7-cb2a3b2e3440	3a499dce-e3dd-46e9-96e2-e3db846599ca	e9775c47-e93f-44f4-bcb4-8f609957ff87	2026-03-09 06:12:03.227639
e072a0d0-66b1-41af-a21f-29cdd40566ad	3a499dce-e3dd-46e9-96e2-e3db846599ca	632d4554-5c84-47bc-b7a9-c2b74a8cb859	2026-03-09 13:31:46.768599
8889642c-5e47-46b5-a566-c790031ef78e	3a499dce-e3dd-46e9-96e2-e3db846599ca	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	2026-03-10 22:35:11.092254
\.


--
-- Data for Name: lobby_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lobby_messages (id, sender_id, content, created_at) FROM stdin;
7eccdf9b-9185-4908-b024-92149fd9f888	3a499dce-e3dd-46e9-96e2-e3db846599ca	gg	2026-03-09 13:32:06.445227
116f140f-593b-47cb-81a7-4de73fdd0626	3a499dce-e3dd-46e9-96e2-e3db846599ca	pp	2026-03-10 12:37:06.320872
6ce37a19-2038-492b-9dc8-1e9be2ce6f44	3a499dce-e3dd-46e9-96e2-e3db846599ca	fff	2026-03-10 13:35:19.693163
5bbf4a53-00c8-489d-872b-768627dab7e1	3a499dce-e3dd-46e9-96e2-e3db846599ca	ff	2026-03-10 13:35:21.097645
24db877d-548d-4619-8263-ddadce512b5a	3a499dce-e3dd-46e9-96e2-e3db846599ca	ff	2026-03-10 13:35:22.425857
6bb5eeff-8ab9-474e-af22-c09d89006406	3a499dce-e3dd-46e9-96e2-e3db846599ca	ff	2026-03-10 13:35:23.77549
0c64c52b-6ac4-40a9-be51-23c83b4bd1eb	3a499dce-e3dd-46e9-96e2-e3db846599ca	eee	2026-03-10 13:51:17.982856
5547ebff-347c-4aae-b574-5b5511084be6	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:20.194561
d5a2429d-d1c8-412d-b5ce-58cc9903490a	3a499dce-e3dd-46e9-96e2-e3db846599ca	eee	2026-03-10 13:51:22.40727
54782fb5-be8d-4d0c-a55d-4bfd496eb054	3a499dce-e3dd-46e9-96e2-e3db846599ca	eee	2026-03-10 13:51:25.174327
30b4f3ed-6d8f-4373-b4ba-34750d4bd31e	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:29.259676
2a094c4c-3395-49a2-b2c3-d23066c329f4	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:30.424573
f38b8fdd-a0f0-49c5-b37c-619fc35df1e6	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:31.694035
1ff453a5-9ecc-4711-b10c-f3c8ed9526d9	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:32.877215
6521bdf3-9eee-4943-8231-80350d245fd5	3a499dce-e3dd-46e9-96e2-e3db846599ca	ee	2026-03-10 13:51:34.124071
355701a8-b57b-4d19-9cd2-34a19dc1edde	3a499dce-e3dd-46e9-96e2-e3db846599ca	g	2026-03-10 16:22:32.327556
9237bbfe-7085-4e4c-a2d0-66d822f7ff55	3a499dce-e3dd-46e9-96e2-e3db846599ca	tt	2026-03-10 16:22:33.676311
e78fb2cd-de2d-40ea-be87-f6ab3d9d26ae	3a499dce-e3dd-46e9-96e2-e3db846599ca	tt	2026-03-10 16:22:34.978749
885a5b1e-0c83-4f79-bb3e-3aa84601b7c9	3a499dce-e3dd-46e9-96e2-e3db846599ca	tt	2026-03-10 16:22:36.284775
dd6279f4-1939-427e-9365-13282457508e	3a499dce-e3dd-46e9-96e2-e3db846599ca	tt	2026-03-10 16:22:37.62528
e6088bcf-e955-43f0-85a8-a9972f499e63	3a499dce-e3dd-46e9-96e2-e3db846599ca	tt	2026-03-10 16:22:39.02355
683ca6a9-01ea-4789-bb92-4ceb05b6ddd5	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	f	2026-03-10 22:31:46.946829
af52fd4f-edd4-40fd-9886-58bd8cb02a59	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	ddd	2026-03-10 22:31:49.871749
561f728f-5b24-4600-b1bf-6cb75b8fbdf6	3a499dce-e3dd-46e9-96e2-e3db846599ca	ww	2026-03-11 01:52:50.1095
c745f64a-a878-440f-af73-286f9df26c8f	3a499dce-e3dd-46e9-96e2-e3db846599ca	ww	2026-03-11 01:52:53.831215
1876969e-7641-4558-8476-4e5ef8f74a95	3a499dce-e3dd-46e9-96e2-e3db846599ca	sss	2026-03-11 01:53:15.893743
8bf145e0-8b69-4397-a66b-b1fd56ed608c	3a499dce-e3dd-46e9-96e2-e3db846599ca	ssssssssssssssssssss	2026-03-11 02:03:15.687905
0bc881e1-e1d9-49cd-ac8f-7395e4a0e043	3a499dce-e3dd-46e9-96e2-e3db846599ca	a	2026-03-11 02:03:23.168978
2ca0ab46-fabb-450c-9d05-869c3ab83364	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	ggg	2026-03-11 02:06:29.58368
40f5d50b-1060-4117-86ee-d7d35f259d7e	3a499dce-e3dd-46e9-96e2-e3db846599ca	loby	2026-03-11 02:09:43.990443
25105aa1-ffe9-418d-87aa-fe66556412f4	3a499dce-e3dd-46e9-96e2-e3db846599ca	rrr	2026-03-11 02:20:09.470375
0f1a9d93-ea8e-4746-8b57-1e4e4103c2ca	3a499dce-e3dd-46e9-96e2-e3db846599ca	ppp	2026-03-11 02:20:13.467
0466070e-a61f-422c-9169-23ef766080f6	3a499dce-e3dd-46e9-96e2-e3db846599ca	o	2026-03-11 02:20:16.713153
45fbb708-0940-4004-a7de-475312cc3367	3a499dce-e3dd-46e9-96e2-e3db846599ca	oo	2026-03-11 02:27:51.406023
\.


--
-- Data for Name: private_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.private_messages (id, sender_id, receiver_id, content, is_read, created_at) FROM stdin;
4f226fcf-4e03-4a05-a092-5c97a335d4bb	3a499dce-e3dd-46e9-96e2-e3db846599ca	632d4554-5c84-47bc-b7a9-c2b74a8cb859	Pp	f	2026-03-09 13:31:58.2331
6d3d7067-8beb-410e-8752-f08dec575e1d	3a499dce-e3dd-46e9-96e2-e3db846599ca	632d4554-5c84-47bc-b7a9-c2b74a8cb859	L	f	2026-03-10 12:36:59.691437
0aa86f11-19fa-4164-b1a9-ad915629a003	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	ddd	f	2026-03-10 13:35:46.014666
f1c3f4d2-e87c-4c65-999c-35adaa30e073	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:35:48.10785
e692b762-038e-4168-ae51-495b01b5fc77	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:35:49.443522
1e22da8f-19c7-4d5d-9cae-ded47d866fcd	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:35:51.626706
ac7c4cfb-be3b-4816-89a3-74e28289b193	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	ddd	f	2026-03-10 13:51:48.972516
8681acb0-5603-42e8-b341-3d81ed10002c	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:51:50.375496
15ebc601-c47e-43e2-a1b9-be4c6d612438	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:51:51.592416
d780275a-9abe-4c78-917b-751d284cbcbf	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:51:54.675775
dd411c7a-e44e-408d-bb88-708f3666b672	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	dd	f	2026-03-10 13:51:55.73229
e6ac1e4e-ea51-410c-9229-2b64e650f161	3a499dce-e3dd-46e9-96e2-e3db846599ca	5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	ssss	f	2026-03-11 02:03:39.170074
452f7f73-f623-4cc4-b2eb-3a8f70e74806	3a499dce-e3dd-46e9-96e2-e3db846599ca	5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	uu	f	2026-03-11 02:05:13.368776
e4457ecb-8e92-4ab9-bbc0-26586ef776d6	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	265cc5c9-b1b3-45d6-8b8c-3daebe8d4e56	dddd	f	2026-03-11 02:06:42.321143
14b803e0-6ed1-47bc-9465-c99024e01c1d	3a499dce-e3dd-46e9-96e2-e3db846599ca	5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	iioooooo	f	2026-03-11 02:08:57.774762
b4d84b95-d12c-4cbf-aa1d-cce151c6b952	3a499dce-e3dd-46e9-96e2-e3db846599ca	5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	ff	f	2026-03-11 02:18:12.255606
47e3f240-2cf6-4a44-95ab-05ecdc965739	3a499dce-e3dd-46e9-96e2-e3db846599ca	5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	DD	f	2026-03-11 02:29:30.252542
\.


--
-- Data for Name: profile_views; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profile_views (id, viewer_id, viewed_id, created_at) FROM stdin;
dea69b0c-21c5-4f9e-96aa-ab40eecd6c9c	3a499dce-e3dd-46e9-96e2-e3db846599ca	e9775c47-e93f-44f4-bcb4-8f609957ff87	2026-03-09 06:12:30.968366
c366cf8d-a690-4fc9-a4ba-6a55f84ee5ce	3a499dce-e3dd-46e9-96e2-e3db846599ca	632d4554-5c84-47bc-b7a9-c2b74a8cb859	2026-03-09 09:44:56.422321
a48b6925-9af6-454f-98ba-45d943327e6f	3a499dce-e3dd-46e9-96e2-e3db846599ca	71c25895-cfea-489b-8787-1cfeadc7ca84	2026-03-10 13:35:40.260632
804ff631-6aba-4572-bf8d-cc53922cb04a	3a499dce-e3dd-46e9-96e2-e3db846599ca	3433cf80-dc0a-44f5-9ec8-8c6380a678d6	2026-03-10 13:53:33.49696
f27dd772-a160-48a8-ada0-c3473cecf12a	3a499dce-e3dd-46e9-96e2-e3db846599ca	7ca5d11a-d4c3-445e-83bf-139c75a6fce3	2026-03-10 20:58:10.392931
a22fe76a-5da7-4201-acb6-06764260f348	3a499dce-e3dd-46e9-96e2-e3db846599ca	2014762e-d19a-45a8-87f5-918e9e77278b	2026-03-10 22:00:04.602818
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reports (id, reporter_id, reported_id, reason, status, created_at) FROM stdin;
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (id, user_id, plan_name, status, starts_at, ends_at) FROM stdin;
\.


--
-- Data for Name: user_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_blocks (id, blocker_id, blocked_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_reports (id, reporter_id, reported_id, reason, status, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, internal_id, email, password_hash, gender, age, city, image, is_vip, role, created_at, eye_color, hair_color, height, sexuality, bio, is_invisible, name, is_banned, last_ip, latitude, longitude) FROM stdin;
632d4554-5c84-47bc-b7a9-c2b74a8cb859	185	user3@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	23	Paris, France	https://randomuser.me/api/portraits/women/3.jpg	f	user	2026-03-09 06:09:28.949281	\N	\N	\N	Straight	Hi! I'm Sofia from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Sofia Brown	f	\N	\N	\N
ba80f02b-12e8-437d-8de0-f1a0c4f6baa7	186	user4@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	24	Berlin, Germany	https://randomuser.me/api/portraits/men/4.jpg	f	user	2026-03-09 06:09:28.950931	\N	\N	\N	Gay	Hi! I'm Luca from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Luca Jones	f	\N	\N	\N
71c25895-cfea-489b-8787-1cfeadc7ca84	189	user7@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	27	Toronto, Canada	https://randomuser.me/api/portraits/women/7.jpg	f	user	2026-03-09 06:09:28.956073	\N	\N	\N	Gay	Hi! I'm Jessica from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Jessica Davis	f	\N	\N	\N
c7246431-586b-4b3e-9577-bfc43b50293a	191	user9@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	29	Madrid, Spain	https://randomuser.me/api/portraits/women/9.jpg	f	user	2026-03-09 06:09:28.959119	\N	\N	\N	Straight	Hi! I'm Maria from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Maria Martinez	f	\N	\N	\N
d862ae98-adb9-41b5-9e09-765b6ed809f9	192	user10@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	30	Seoul, South Korea	https://randomuser.me/api/portraits/men/10.jpg	f	user	2026-03-09 06:09:28.96083	\N	\N	\N	Gay	Hi! I'm Alejandro from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Alejandro Hernandez	f	\N	\N	\N
2f495995-92ad-4b63-afa8-089126ab9de4	193	user11@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	31	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/women/11.jpg	f	user	2026-03-09 06:09:28.962461	\N	\N	\N	Bisexual	Hi! I'm Valeria from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Valeria Lopez	f	\N	\N	\N
bd662123-f5f3-483b-ac25-625265c743f1	194	user12@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	32	Mexico City, Mexico	https://randomuser.me/api/portraits/men/12.jpg	f	user	2026-03-09 06:09:28.964045	\N	\N	\N	Straight	Hi! I'm Lucas from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Lucas Gonzalez	f	\N	\N	\N
6f0d7f7a-1907-4a11-9864-398bb706a8b6	195	user13@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	33	Amsterdam, Netherlands	https://randomuser.me/api/portraits/women/13.jpg	f	user	2026-03-09 06:09:28.96566	\N	\N	\N	Gay	Hi! I'm Mia from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Mia Wilson	f	\N	\N	\N
c2257f49-efe9-47cb-b3c6-bf394b2defc4	196	user14@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	34	Vienna, Austria	https://randomuser.me/api/portraits/men/14.jpg	f	user	2026-03-09 06:09:28.967327	\N	\N	\N	Bisexual	Hi! I'm Noah from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Noah Anderson	f	\N	\N	\N
5e2d434f-9ccf-4000-83ed-b58893d4871c	197	user15@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	35	New York, USA	https://randomuser.me/api/portraits/women/15.jpg	f	user	2026-03-09 06:09:28.968986	\N	\N	\N	Straight	Hi! I'm Emma from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	Emma Smith	f	\N	\N	\N
bb0aa16a-538d-4066-bdbe-79731a8319c9	198	user16@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	36	London, UK	https://randomuser.me/api/portraits/men/16.jpg	f	user	2026-03-09 06:09:28.970783	\N	\N	\N	Gay	Hi! I'm Mateo from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Mateo Johnson	f	\N	\N	\N
33d65e74-aee5-416c-a4d6-5cf6e83f3068	199	user17@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	37	Tokyo, Japan	https://randomuser.me/api/portraits/women/17.jpg	f	user	2026-03-09 06:09:28.972716	\N	\N	\N	Bisexual	Hi! I'm Jennifer from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Jennifer Williams	f	\N	\N	\N
3592f6e6-7916-4708-9f08-967aadb51983	200	user18@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	38	Paris, France	https://randomuser.me/api/portraits/men/18.jpg	f	user	2026-03-09 06:09:28.974288	\N	\N	\N	Straight	Hi! I'm Michael from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Michael Brown	f	\N	\N	\N
cfd050d5-ed8b-41dd-a460-7a841e007e76	201	user19@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	39	Berlin, Germany	https://randomuser.me/api/portraits/women/19.jpg	f	user	2026-03-09 06:09:28.976008	\N	\N	\N	Gay	Hi! I'm Elizabeth from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Elizabeth Jones	f	\N	\N	\N
a6c9898b-5b1f-47cd-869a-4b425fe13e6b	202	user20@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	40	Sydney, Australia	https://randomuser.me/api/portraits/men/20.jpg	f	user	2026-03-09 06:09:28.978031	\N	\N	\N	Bisexual	Hi! I'm David from Sydney, Australia. I love traveling, trying new food, and meeting new people from all over the world!	f	David Garcia	f	\N	\N	\N
4d2ebf91-63d9-48db-afeb-2be24e4a39ef	203	user21@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	41	Dubai, UAE	https://randomuser.me/api/portraits/women/21.jpg	f	user	2026-03-09 06:09:28.979732	\N	\N	\N	Straight	Hi! I'm Susan from Dubai, UAE. I love traveling, trying new food, and meeting new people from all over the world!	f	Susan Miller	f	\N	\N	\N
c7ee2924-aeb8-4dc8-8329-f0710095d8fe	184	user2@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	22	Tokyo, Japan	https://randomuser.me/api/portraits/men/2.jpg	f	user	2026-03-09 06:09:28.944882	\N	\N	\N	Bisexual	Hi! I'm Robert from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Robert Williams	f	\N	\N	\N
3433cf80-dc0a-44f5-9ec8-8c6380a678d6	190	user8@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	28	Rome, Italy	https://randomuser.me/api/portraits/men/8.jpg	f	user	2026-03-09 06:09:28.957716	\N	\N	\N	Bisexual	Hi! I'm Thomas from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Thomas Rodriguez	f	\N	\N	\N
7ca5d11a-d4c3-445e-83bf-139c75a6fce3	274	info@vmixingmastering.com	$2b$10$94hAPQkA4Q0fGGsk2zDMBuNIE1zch0S9xr2cJBErpZOWtH.PSKwku	Female	\N	\N	\N	f	user	2026-03-10 20:57:27.747171	\N	\N	\N	\N	\N	f	MMMMM LLLL	f	\N	\N	\N
2014762e-d19a-45a8-87f5-918e9e77278b	204	user22@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	42	Toronto, Canada	https://randomuser.me/api/portraits/men/22.jpg	f	user	2026-03-09 06:09:28.981447	\N	\N	\N	Gay	Hi! I'm Joseph from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Joseph Davis	f	\N	\N	\N
68e53475-43c8-470e-ae10-fcf7886749d8	205	user23@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	43	Rome, Italy	https://randomuser.me/api/portraits/women/23.jpg	f	user	2026-03-09 06:09:28.982986	\N	\N	\N	Bisexual	Hi! I'm Sarah from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Sarah Rodriguez	f	\N	\N	\N
637c853b-9f86-4c13-b4f6-7180c9f5699f	206	user24@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	44	Madrid, Spain	https://randomuser.me/api/portraits/men/24.jpg	f	user	2026-03-09 06:09:28.984347	\N	\N	\N	Straight	Hi! I'm Carlos from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Carlos Martinez	f	\N	\N	\N
1d3f6e0d-3ed4-470b-8ab8-c0eaf8599dab	207	user25@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	45	Seoul, South Korea	https://randomuser.me/api/portraits/women/25.jpg	f	user	2026-03-09 06:09:28.98609	\N	\N	\N	Gay	Hi! I'm Camila from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Camila Hernandez	f	\N	\N	\N
6aa38b8d-c97d-4397-b231-261cd491e7ee	208	user26@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	20	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/men/26.jpg	f	user	2026-03-09 06:09:28.987771	\N	\N	\N	Bisexual	Hi! I'm Ivan from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Ivan Lopez	f	\N	\N	\N
39ad80d7-d0ae-4aa9-81ab-fcd6aac49a2b	209	user27@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	21	Mexico City, Mexico	https://randomuser.me/api/portraits/women/27.jpg	f	user	2026-03-09 06:09:28.989522	\N	\N	\N	Straight	Hi! I'm Isabella from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Isabella Gonzalez	f	\N	\N	\N
9abcc706-d812-4d59-a106-abd4684e1432	210	user28@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	22	Amsterdam, Netherlands	https://randomuser.me/api/portraits/men/28.jpg	f	user	2026-03-09 06:09:28.991386	\N	\N	\N	Gay	Hi! I'm Oliver from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Oliver Wilson	f	\N	\N	\N
93b0084f-8bb4-4975-bb54-f5808e192e1e	211	user29@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	23	Vienna, Austria	https://randomuser.me/api/portraits/women/29.jpg	f	user	2026-03-09 06:09:28.993205	\N	\N	\N	Bisexual	Hi! I'm Ava from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Ava Anderson	f	\N	\N	\N
1b1959cf-d23d-422f-a0f0-7c03d888e81c	212	user30@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	24	New York, USA	https://randomuser.me/api/portraits/men/30.jpg	f	user	2026-03-09 06:09:28.995535	\N	\N	\N	Straight	Hi! I'm James from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	James Smith	f	\N	\N	\N
3ea65895-c1b8-4c6c-b51a-9485023a3772	213	user31@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	25	London, UK	https://randomuser.me/api/portraits/women/31.jpg	f	user	2026-03-09 06:09:28.99698	\N	\N	\N	Gay	Hi! I'm Patricia from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Patricia Johnson	f	\N	\N	\N
bdf90234-50dd-4c46-b35b-101847862767	214	user32@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	26	Tokyo, Japan	https://randomuser.me/api/portraits/men/32.jpg	f	user	2026-03-09 06:09:28.998353	\N	\N	\N	Bisexual	Hi! I'm Robert from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Robert Williams	f	\N	\N	\N
7b659571-589f-45dc-bddf-f840dd94a81d	215	user33@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	27	Paris, France	https://randomuser.me/api/portraits/women/33.jpg	f	user	2026-03-09 06:09:28.999609	\N	\N	\N	Straight	Hi! I'm Sofia from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Sofia Brown	f	\N	\N	\N
544f067a-5af2-4e10-8c67-917aa5060b34	216	user34@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	28	Berlin, Germany	https://randomuser.me/api/portraits/men/34.jpg	f	user	2026-03-09 06:09:29.001413	\N	\N	\N	Gay	Hi! I'm Luca from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Luca Jones	f	\N	\N	\N
b408acc2-c96d-483b-8db5-d354d1677567	217	user35@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	29	Sydney, Australia	https://randomuser.me/api/portraits/women/35.jpg	f	user	2026-03-09 06:09:29.003181	\N	\N	\N	Bisexual	Hi! I'm Barbara from Sydney, Australia. I love traveling, trying new food, and meeting new people from all over the world!	f	Barbara Garcia	f	\N	\N	\N
81f9693a-6f72-4933-8551-e00ac0e60a05	218	user36@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	30	Dubai, UAE	https://randomuser.me/api/portraits/men/36.jpg	f	user	2026-03-09 06:09:29.005194	\N	\N	\N	Straight	Hi! I'm Richard from Dubai, UAE. I love traveling, trying new food, and meeting new people from all over the world!	f	Richard Miller	f	\N	\N	\N
258e526c-bec6-4425-a09a-5577139e0481	219	user37@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	31	Toronto, Canada	https://randomuser.me/api/portraits/women/37.jpg	f	user	2026-03-09 06:09:29.00701	\N	\N	\N	Gay	Hi! I'm Jessica from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Jessica Davis	f	\N	\N	\N
a8823870-ab2a-40d7-ba78-da8657403f40	220	user38@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	32	Rome, Italy	https://randomuser.me/api/portraits/men/38.jpg	f	user	2026-03-09 06:09:29.008661	\N	\N	\N	Bisexual	Hi! I'm Thomas from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Thomas Rodriguez	f	\N	\N	\N
3c5c0049-da22-445e-9bf7-b1af17fd8e23	221	user39@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	33	Madrid, Spain	https://randomuser.me/api/portraits/women/39.jpg	f	user	2026-03-09 06:09:29.01104	\N	\N	\N	Straight	Hi! I'm Maria from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Maria Martinez	f	\N	\N	\N
d7eaaad3-ff63-4262-82e9-4df095feb1f1	222	user40@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	34	Seoul, South Korea	https://randomuser.me/api/portraits/men/40.jpg	f	user	2026-03-09 06:09:29.012791	\N	\N	\N	Gay	Hi! I'm Alejandro from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Alejandro Hernandez	f	\N	\N	\N
ad6fd93b-a60e-4c5e-9c65-e41e85bf09a4	223	user41@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	35	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/women/41.jpg	f	user	2026-03-09 06:09:29.014379	\N	\N	\N	Bisexual	Hi! I'm Valeria from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Valeria Lopez	f	\N	\N	\N
b2150b39-c809-4fb2-8bbd-d2b84eef67fa	224	user42@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	36	Mexico City, Mexico	https://randomuser.me/api/portraits/men/42.jpg	f	user	2026-03-09 06:09:29.015996	\N	\N	\N	Straight	Hi! I'm Lucas from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Lucas Gonzalez	f	\N	\N	\N
0d433037-f364-4a8e-8395-3cb763552d0c	225	user43@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	37	Amsterdam, Netherlands	https://randomuser.me/api/portraits/women/43.jpg	f	user	2026-03-09 06:09:29.017554	\N	\N	\N	Gay	Hi! I'm Mia from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Mia Wilson	f	\N	\N	\N
259cb909-febf-43f1-95ef-be3974552096	226	user44@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	38	Vienna, Austria	https://randomuser.me/api/portraits/men/44.jpg	f	user	2026-03-09 06:09:29.019128	\N	\N	\N	Bisexual	Hi! I'm Noah from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Noah Anderson	f	\N	\N	\N
78181b98-388f-45b4-bfd5-ff594cd487aa	227	user45@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	39	New York, USA	https://randomuser.me/api/portraits/women/45.jpg	f	user	2026-03-09 06:09:29.020715	\N	\N	\N	Straight	Hi! I'm Emma from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	Emma Smith	f	\N	\N	\N
d45647f0-f465-44b9-846b-eff3a8c1eaab	228	user46@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	40	London, UK	https://randomuser.me/api/portraits/men/46.jpg	f	user	2026-03-09 06:09:29.022509	\N	\N	\N	Gay	Hi! I'm Mateo from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Mateo Johnson	f	\N	\N	\N
01dade81-e3c3-4498-8416-a604e3063ed4	229	user47@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	41	Tokyo, Japan	https://randomuser.me/api/portraits/women/47.jpg	f	user	2026-03-09 06:09:29.024287	\N	\N	\N	Bisexual	Hi! I'm Jennifer from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Jennifer Williams	f	\N	\N	\N
e20c7628-422f-4a9f-afba-95aa85a2c536	230	user48@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	42	Paris, France	https://randomuser.me/api/portraits/men/48.jpg	f	user	2026-03-09 06:09:29.025797	\N	\N	\N	Straight	Hi! I'm Michael from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Michael Brown	f	\N	\N	\N
420cf31d-7ba1-4875-86ff-83b7c1f4a749	231	user49@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	43	Berlin, Germany	https://randomuser.me/api/portraits/women/49.jpg	f	user	2026-03-09 06:09:29.027539	\N	\N	\N	Gay	Hi! I'm Elizabeth from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Elizabeth Jones	f	\N	\N	\N
fd0e3a7f-d579-48d1-806d-4dafcf950970	232	user50@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	44	Sydney, Australia	https://randomuser.me/api/portraits/men/50.jpg	f	user	2026-03-09 06:09:29.029125	\N	\N	\N	Bisexual	Hi! I'm David from Sydney, Australia. I love traveling, trying new food, and meeting new people from all over the world!	f	David Garcia	f	\N	\N	\N
6d82d1dc-12cc-4814-a235-1b280b52ae20	233	user51@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	45	Dubai, UAE	https://randomuser.me/api/portraits/women/51.jpg	f	user	2026-03-09 06:09:29.030626	\N	\N	\N	Straight	Hi! I'm Susan from Dubai, UAE. I love traveling, trying new food, and meeting new people from all over the world!	f	Susan Miller	f	\N	\N	\N
e9775c47-e93f-44f4-bcb4-8f609957ff87	183	user1@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	21	London, UK	https://randomuser.me/api/portraits/women/1.jpg	f	user	2026-03-09 06:09:28.930487	\N	\N	\N	Gay	Hi! I'm Patricia from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Patricia Johnson	t	\N	\N	\N
3a499dce-e3dd-46e9-96e2-e3db846599ca	2	admin@test.com	$2a$10$.5Elh8fgxypNUWhpUUr/xOa2sZm0VIaE0qWuGGl9otUfobb46T1Pq	Male	\N	\N	\N	t	admin	2026-03-06 04:52:03.143035	\N	\N	\N	\N	\N	f	Admin	f	\N	\N	\N
7b9610ee-f8bf-450f-8568-2586c1ad4acf	234	user52@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	20	Toronto, Canada	https://randomuser.me/api/portraits/men/52.jpg	f	user	2026-03-09 06:09:29.032282	\N	\N	\N	Gay	Hi! I'm Joseph from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Joseph Davis	f	\N	\N	\N
39006e64-c872-4e54-bc77-eda213d4a5aa	235	user53@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	21	Rome, Italy	https://randomuser.me/api/portraits/women/53.jpg	f	user	2026-03-09 06:09:29.033941	\N	\N	\N	Bisexual	Hi! I'm Sarah from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Sarah Rodriguez	f	\N	\N	\N
3eff0526-b684-41e6-b3be-08f2df1bd45d	236	user54@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	22	Madrid, Spain	https://randomuser.me/api/portraits/men/54.jpg	f	user	2026-03-09 06:09:29.03562	\N	\N	\N	Straight	Hi! I'm Carlos from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Carlos Martinez	f	\N	\N	\N
7e42128e-015f-4b95-8b7e-4c5762ac9e6c	237	user55@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	23	Seoul, South Korea	https://randomuser.me/api/portraits/women/55.jpg	f	user	2026-03-09 06:09:29.037104	\N	\N	\N	Gay	Hi! I'm Camila from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Camila Hernandez	f	\N	\N	\N
efff612e-fb60-4660-a92d-cc4dac080855	238	user56@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	24	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/men/56.jpg	f	user	2026-03-09 06:09:29.039212	\N	\N	\N	Bisexual	Hi! I'm Ivan from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Ivan Lopez	f	\N	\N	\N
e03f97ad-a4b9-4d3a-9189-9ac94c95cef9	239	user57@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	25	Mexico City, Mexico	https://randomuser.me/api/portraits/women/57.jpg	f	user	2026-03-09 06:09:29.041086	\N	\N	\N	Straight	Hi! I'm Isabella from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Isabella Gonzalez	f	\N	\N	\N
26d30653-e08a-427c-8080-8bbb6234c16e	240	user58@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	26	Amsterdam, Netherlands	https://randomuser.me/api/portraits/men/58.jpg	f	user	2026-03-09 06:09:29.043097	\N	\N	\N	Gay	Hi! I'm Oliver from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Oliver Wilson	f	\N	\N	\N
280c7fe5-2ba7-42c8-bed9-17e0411cbdbb	241	user59@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	27	Vienna, Austria	https://randomuser.me/api/portraits/women/59.jpg	f	user	2026-03-09 06:09:29.045358	\N	\N	\N	Bisexual	Hi! I'm Ava from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Ava Anderson	f	\N	\N	\N
dc2f9028-2fb5-40ad-9ff2-3f5880ad48c2	242	user60@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	28	New York, USA	https://randomuser.me/api/portraits/men/60.jpg	f	user	2026-03-09 06:09:29.047143	\N	\N	\N	Straight	Hi! I'm James from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	James Smith	f	\N	\N	\N
27a8b414-d4aa-4a4b-945d-93737586d4b1	243	user61@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	29	London, UK	https://randomuser.me/api/portraits/women/61.jpg	f	user	2026-03-09 06:09:29.048713	\N	\N	\N	Gay	Hi! I'm Patricia from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Patricia Johnson	f	\N	\N	\N
a389efb2-7a9b-412f-9ebf-0b2b2bb5ca42	244	user62@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	30	Tokyo, Japan	https://randomuser.me/api/portraits/men/62.jpg	f	user	2026-03-09 06:09:29.05013	\N	\N	\N	Bisexual	Hi! I'm Robert from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Robert Williams	f	\N	\N	\N
9a84aa36-e308-4b91-b5b6-796f86ec2d49	245	user63@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	31	Paris, France	https://randomuser.me/api/portraits/women/63.jpg	f	user	2026-03-09 06:09:29.051691	\N	\N	\N	Straight	Hi! I'm Sofia from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Sofia Brown	f	\N	\N	\N
487c4a53-0586-48f0-b884-0a3ec1de2fcc	246	user64@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	32	Berlin, Germany	https://randomuser.me/api/portraits/men/64.jpg	f	user	2026-03-09 06:09:29.05324	\N	\N	\N	Gay	Hi! I'm Luca from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Luca Jones	f	\N	\N	\N
31f57ae5-2146-4600-82c2-a5e992fe6dda	247	user65@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	33	Sydney, Australia	https://randomuser.me/api/portraits/women/65.jpg	f	user	2026-03-09 06:09:29.055181	\N	\N	\N	Bisexual	Hi! I'm Barbara from Sydney, Australia. I love traveling, trying new food, and meeting new people from all over the world!	f	Barbara Garcia	f	\N	\N	\N
3ac637ef-4d40-43b9-b0b4-323c37967467	248	user66@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	34	Dubai, UAE	https://randomuser.me/api/portraits/men/66.jpg	f	user	2026-03-09 06:09:29.056889	\N	\N	\N	Straight	Hi! I'm Richard from Dubai, UAE. I love traveling, trying new food, and meeting new people from all over the world!	f	Richard Miller	f	\N	\N	\N
2ac5c204-78c6-45da-ac0d-68f3c8800cdb	249	user67@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	35	Toronto, Canada	https://randomuser.me/api/portraits/women/67.jpg	f	user	2026-03-09 06:09:29.05855	\N	\N	\N	Gay	Hi! I'm Jessica from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Jessica Davis	f	\N	\N	\N
bd22d0c8-84a2-4d79-aad7-952eecdae868	250	user68@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	36	Rome, Italy	https://randomuser.me/api/portraits/men/68.jpg	f	user	2026-03-09 06:09:29.060324	\N	\N	\N	Bisexual	Hi! I'm Thomas from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Thomas Rodriguez	f	\N	\N	\N
267e6ad0-2b56-44bc-8547-92af17d77194	251	user69@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	37	Madrid, Spain	https://randomuser.me/api/portraits/women/69.jpg	f	user	2026-03-09 06:09:29.062331	\N	\N	\N	Straight	Hi! I'm Maria from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Maria Martinez	f	\N	\N	\N
9701b001-e2d5-49cf-8f4d-e900b88092a7	252	user70@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	38	Seoul, South Korea	https://randomuser.me/api/portraits/men/70.jpg	f	user	2026-03-09 06:09:29.063988	\N	\N	\N	Gay	Hi! I'm Alejandro from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Alejandro Hernandez	f	\N	\N	\N
17088b27-ff1e-4675-9f56-31b22d50178e	253	user71@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	39	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/women/71.jpg	f	user	2026-03-09 06:09:29.065741	\N	\N	\N	Bisexual	Hi! I'm Valeria from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Valeria Lopez	f	\N	\N	\N
483c581d-76e4-42a3-98d1-175dd9474b6d	254	user72@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	40	Mexico City, Mexico	https://randomuser.me/api/portraits/men/72.jpg	f	user	2026-03-09 06:09:29.067616	\N	\N	\N	Straight	Hi! I'm Lucas from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Lucas Gonzalez	f	\N	\N	\N
2d273657-35fd-4bff-b769-c8aacd1ab174	255	user73@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	41	Amsterdam, Netherlands	https://randomuser.me/api/portraits/women/73.jpg	f	user	2026-03-09 06:09:29.069084	\N	\N	\N	Gay	Hi! I'm Mia from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Mia Wilson	f	\N	\N	\N
20f7e2a3-7ee6-4ebb-a29f-2a6e357181f6	256	user74@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	42	Vienna, Austria	https://randomuser.me/api/portraits/men/74.jpg	f	user	2026-03-09 06:09:29.070853	\N	\N	\N	Bisexual	Hi! I'm Noah from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Noah Anderson	f	\N	\N	\N
ebcfa0bc-454b-41b7-8be4-73535084c7e3	257	user75@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	43	New York, USA	https://randomuser.me/api/portraits/women/75.jpg	f	user	2026-03-09 06:09:29.07232	\N	\N	\N	Straight	Hi! I'm Emma from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	Emma Smith	f	\N	\N	\N
8f8e400c-31b5-497d-bd82-d0120dea1994	258	user76@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	44	London, UK	https://randomuser.me/api/portraits/men/76.jpg	f	user	2026-03-09 06:09:29.074031	\N	\N	\N	Gay	Hi! I'm Mateo from London, UK. I love traveling, trying new food, and meeting new people from all over the world!	f	Mateo Johnson	f	\N	\N	\N
51a33e70-c181-4fa0-ae86-34f2507a1980	259	user77@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	45	Tokyo, Japan	https://randomuser.me/api/portraits/women/77.jpg	f	user	2026-03-09 06:09:29.075881	\N	\N	\N	Bisexual	Hi! I'm Jennifer from Tokyo, Japan. I love traveling, trying new food, and meeting new people from all over the world!	f	Jennifer Williams	f	\N	\N	\N
f6a013a6-d3a0-46e2-a63b-51413c980de0	260	user78@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	20	Paris, France	https://randomuser.me/api/portraits/men/78.jpg	f	user	2026-03-09 06:09:29.077895	\N	\N	\N	Straight	Hi! I'm Michael from Paris, France. I love traveling, trying new food, and meeting new people from all over the world!	f	Michael Brown	f	\N	\N	\N
e6b1098d-924f-456e-bb75-abca8d97c424	261	user79@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	21	Berlin, Germany	https://randomuser.me/api/portraits/women/79.jpg	f	user	2026-03-09 06:09:29.080011	\N	\N	\N	Gay	Hi! I'm Elizabeth from Berlin, Germany. I love traveling, trying new food, and meeting new people from all over the world!	f	Elizabeth Jones	f	\N	\N	\N
799eb021-7833-46d1-802a-5eebff0d8628	262	user80@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	22	Sydney, Australia	https://randomuser.me/api/portraits/men/80.jpg	f	user	2026-03-09 06:09:29.081822	\N	\N	\N	Bisexual	Hi! I'm David from Sydney, Australia. I love traveling, trying new food, and meeting new people from all over the world!	f	David Garcia	f	\N	\N	\N
7ad72786-c0d5-412b-a97e-c9a2e876114a	263	user81@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	23	Dubai, UAE	https://randomuser.me/api/portraits/women/81.jpg	f	user	2026-03-09 06:09:29.08369	\N	\N	\N	Straight	Hi! I'm Susan from Dubai, UAE. I love traveling, trying new food, and meeting new people from all over the world!	f	Susan Miller	f	\N	\N	\N
c19a5282-47f7-4677-a097-ea9454eaf1bf	264	user82@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	24	Toronto, Canada	https://randomuser.me/api/portraits/men/82.jpg	f	user	2026-03-09 06:09:29.085254	\N	\N	\N	Gay	Hi! I'm Joseph from Toronto, Canada. I love traveling, trying new food, and meeting new people from all over the world!	f	Joseph Davis	f	\N	\N	\N
aec39f09-8213-4b24-9483-5f7d7e69503c	265	user83@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	25	Rome, Italy	https://randomuser.me/api/portraits/women/83.jpg	f	user	2026-03-09 06:09:29.086926	\N	\N	\N	Bisexual	Hi! I'm Sarah from Rome, Italy. I love traveling, trying new food, and meeting new people from all over the world!	f	Sarah Rodriguez	f	\N	\N	\N
c10eecbf-3953-4f4b-8a05-c6bf797703b8	266	user84@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	26	Madrid, Spain	https://randomuser.me/api/portraits/men/84.jpg	f	user	2026-03-09 06:09:29.088871	\N	\N	\N	Straight	Hi! I'm Carlos from Madrid, Spain. I love traveling, trying new food, and meeting new people from all over the world!	f	Carlos Martinez	f	\N	\N	\N
81f2cec5-4ccf-4949-99ba-1a3484ecc5db	267	user85@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	27	Seoul, South Korea	https://randomuser.me/api/portraits/women/85.jpg	f	user	2026-03-09 06:09:29.090252	\N	\N	\N	Gay	Hi! I'm Camila from Seoul, South Korea. I love traveling, trying new food, and meeting new people from all over the world!	f	Camila Hernandez	f	\N	\N	\N
0ff54b9b-721c-4fff-9ba5-d1b2111a2fc8	268	user86@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	28	Rio de Janeiro, Brazil	https://randomuser.me/api/portraits/men/86.jpg	f	user	2026-03-09 06:09:29.091735	\N	\N	\N	Bisexual	Hi! I'm Ivan from Rio de Janeiro, Brazil. I love traveling, trying new food, and meeting new people from all over the world!	f	Ivan Lopez	f	\N	\N	\N
6927d012-e0d9-45cc-a11a-7791a0177de5	269	user87@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	29	Mexico City, Mexico	https://randomuser.me/api/portraits/women/87.jpg	f	user	2026-03-09 06:09:29.09353	\N	\N	\N	Straight	Hi! I'm Isabella from Mexico City, Mexico. I love traveling, trying new food, and meeting new people from all over the world!	f	Isabella Gonzalez	f	\N	\N	\N
76d69331-2f97-4785-a7e5-1b38ebd68d51	270	user88@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	30	Amsterdam, Netherlands	https://randomuser.me/api/portraits/men/88.jpg	f	user	2026-03-09 06:09:29.095304	\N	\N	\N	Gay	Hi! I'm Oliver from Amsterdam, Netherlands. I love traveling, trying new food, and meeting new people from all over the world!	f	Oliver Wilson	f	\N	\N	\N
265cc5c9-b1b3-45d6-8b8c-3daebe8d4e56	271	user89@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Female	31	Vienna, Austria	https://randomuser.me/api/portraits/women/89.jpg	f	user	2026-03-09 06:09:29.096775	\N	\N	\N	Bisexual	Hi! I'm Ava from Vienna, Austria. I love traveling, trying new food, and meeting new people from all over the world!	f	Ava Anderson	f	\N	\N	\N
5f8dd6e8-ac9d-4adc-8f62-3729ce462dbe	272	user90@test.com	$2b$10$nPSUybZC61FVZldu4Mjeqe2JxTn0Lstks42hbaBmr8G99/wkNCQKa	Male	32	New York, USA	https://randomuser.me/api/portraits/men/0.jpg	f	user	2026-03-09 06:09:29.098301	\N	\N	\N	Straight	Hi! I'm James from New York, USA. I love traveling, trying new food, and meeting new people from all over the world!	f	James Smith	f	\N	\N	\N
\.


--
-- Data for Name: video_calls; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_calls (id, caller_id, receiver_id, status, duration_seconds, created_at) FROM stdin;
\.


--
-- Name: gallery_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gallery_images_id_seq', 1, false);


--
-- Name: user_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_blocks_id_seq', 1, false);


--
-- Name: user_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_reports_id_seq', 1, false);


--
-- Name: users_internal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_internal_id_seq', 274, true);


--
-- Name: banned_ips banned_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banned_ips
    ADD CONSTRAINT banned_ips_pkey PRIMARY KEY (ip);


--
-- Name: blocks blocks_blocker_id_blocked_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_id_blocked_id_key UNIQUE (blocker_id, blocked_id);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: friends friends_user_id_friend_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_friend_id_key UNIQUE (user_id, friend_id);


--
-- Name: gallery_images gallery_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_images
    ADD CONSTRAINT gallery_images_pkey PRIMARY KEY (id);


--
-- Name: gifts gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gifts
    ADD CONSTRAINT gifts_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: likes likes_user_id_liked_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_liked_user_id_key UNIQUE (user_id, liked_user_id);


--
-- Name: lobby_messages lobby_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lobby_messages
    ADD CONSTRAINT lobby_messages_pkey PRIMARY KEY (id);


--
-- Name: private_messages private_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_pkey PRIMARY KEY (id);


--
-- Name: profile_views profile_views_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_views
    ADD CONSTRAINT profile_views_pkey PRIMARY KEY (id);


--
-- Name: profile_views profile_views_viewer_id_viewed_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_views
    ADD CONSTRAINT profile_views_viewer_id_viewed_id_key UNIQUE (viewer_id, viewed_id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_blocks user_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_pkey PRIMARY KEY (id);


--
-- Name: user_reports user_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT user_reports_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_internal_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_internal_id_key UNIQUE (internal_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: video_calls video_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT video_calls_pkey PRIMARY KEY (id);


--
-- Name: idx_blocks_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_active ON public.blocks USING btree (blocker_id, blocked_id);


--
-- Name: idx_gallery_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gallery_user_id ON public.gallery_images USING btree (user_id);


--
-- Name: idx_likes_who_liked_me; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_who_liked_me ON public.likes USING btree (liked_user_id, created_at DESC);


--
-- Name: idx_priv_msg_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_priv_msg_conversation ON public.private_messages USING btree (sender_id, receiver_id, created_at DESC);


--
-- Name: idx_priv_msg_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_priv_msg_unread ON public.private_messages USING btree (receiver_id) WHERE (is_read = false);


--
-- Name: idx_private_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_created ON public.private_messages USING btree (created_at DESC);


--
-- Name: idx_private_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_receiver ON public.private_messages USING btree (receiver_id);


--
-- Name: idx_private_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_sender ON public.private_messages USING btree (sender_id);


--
-- Name: idx_profile_views_viewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profile_views_viewed ON public.profile_views USING btree (viewed_id, created_at DESC);


--
-- Name: idx_subscriptions_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscriptions_active ON public.subscriptions USING btree (user_id) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_users_discovery; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_discovery ON public.users USING btree (city, gender, age);


--
-- Name: idx_users_vips; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_vips ON public.users USING btree (id) WHERE (is_vip = true);


--
-- Name: blocks blocks_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_blocker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: gallery_images gallery_images_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_images
    ADD CONSTRAINT gallery_images_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: gifts gifts_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gifts
    ADD CONSTRAINT gifts_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: gifts gifts_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gifts
    ADD CONSTRAINT gifts_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: likes likes_liked_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_liked_user_id_fkey FOREIGN KEY (liked_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: likes likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lobby_messages lobby_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lobby_messages
    ADD CONSTRAINT lobby_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: private_messages private_messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: private_messages private_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profile_views profile_views_viewed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_views
    ADD CONSTRAINT profile_views_viewed_id_fkey FOREIGN KEY (viewed_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profile_views profile_views_viewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_views
    ADD CONSTRAINT profile_views_viewer_id_fkey FOREIGN KEY (viewer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports reports_reported_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reported_id_fkey FOREIGN KEY (reported_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: video_calls video_calls_caller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT video_calls_caller_id_fkey FOREIGN KEY (caller_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: video_calls video_calls_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_calls
    ADD CONSTRAINT video_calls_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict FCrFrEoAHbJTg9UbtVMwE5yrIg4pnjKb7b96F8Mu1rsogaOqGy0UnNODEt4CqJr

