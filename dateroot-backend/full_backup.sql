--
-- PostgreSQL database dump
--

\restrict fJDGMH1JGDJDSSw1fDR5jF2nYJBnRhz1IPUn1WP7dSFg8odmMO9Kc9fmaBKbsbO

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


--
-- Name: handle_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_updated_at() OWNER TO postgres;

--
-- Name: has_active_subscription(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.has_active_subscription(user_uuid uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM subscriptions
    WHERE user_id = user_uuid
    AND status = 'active'
    AND expires_at > NOW()
  );
END;
$$;


ALTER FUNCTION public.has_active_subscription(user_uuid uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: affiliate_commissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.affiliate_commissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    affiliate_id uuid,
    referred_user_id uuid,
    amount numeric(10,2) NOT NULL,
    manual_payment_id uuid,
    package_name text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.affiliate_commissions OWNER TO postgres;

--
-- Name: blocked_ips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocked_ips (
    ip_address text NOT NULL,
    reason text,
    banned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.blocked_ips OWNER TO postgres;

--
-- Name: chat_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_reports (
    id integer NOT NULL,
    reporter_id uuid,
    reported_id uuid,
    reason text,
    message_preview text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.chat_reports OWNER TO postgres;

--
-- Name: chat_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_reports_id_seq OWNER TO postgres;

--
-- Name: chat_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_reports_id_seq OWNED BY public.chat_reports.id;


--
-- Name: drip_campaigns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drip_campaigns (
    user_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    last_message_at timestamp with time zone,
    next_message_at timestamp with time zone,
    message_count integer DEFAULT 0,
    is_active boolean DEFAULT true
);


ALTER TABLE public.drip_campaigns OWNER TO postgres;

--
-- Name: favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    favorited_user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.favorites OWNER TO postgres;

--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friends (
    id uuid DEFAULT gen_random_uuid() CONSTRAINT friendships_id_not_null NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    status text DEFAULT 'pending'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.friends OWNER TO postgres;

--
-- Name: gifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gifts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    icon text NOT NULL,
    cost integer NOT NULL
);


ALTER TABLE public.gifts OWNER TO postgres;

--
-- Name: hidden_chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hidden_chats (
    user_id uuid NOT NULL,
    hidden_user_id uuid NOT NULL,
    hidden_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.hidden_chats OWNER TO postgres;

--
-- Name: lobby_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lobby_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.lobby_messages OWNER TO postgres;

--
-- Name: manual_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manual_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    amount numeric(10,2),
    package_name text,
    receipt_url text,
    status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.manual_payments OWNER TO postgres;

--
-- Name: message_limits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_limits (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    chat_type text NOT NULL,
    conversation_id text,
    message_count integer DEFAULT 0,
    reset_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    last_message_at timestamp with time zone DEFAULT now(),
    CONSTRAINT message_limits_chat_type_check CHECK ((chat_type = ANY (ARRAY['lobby'::text, 'private'::text])))
);


ALTER TABLE public.message_limits OWNER TO postgres;

--
-- Name: payout_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payout_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    amount numeric(10,2) NOT NULL,
    payment_details text NOT NULL,
    status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.payout_requests OWNER TO postgres;

--
-- Name: private_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.private_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id text,
    sender_id uuid,
    receiver_id uuid,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_read boolean DEFAULT false
);


ALTER TABLE public.private_messages OWNER TO postgres;

--
-- Name: profile_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_images (
    id integer NOT NULL,
    profile_id integer,
    image_url text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.profile_images OWNER TO postgres;

--
-- Name: profile_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profile_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profile_images_id_seq OWNER TO postgres;

--
-- Name: profile_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profile_images_id_seq OWNED BY public.profile_images.id;


--
-- Name: profile_visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_visits (
    id integer NOT NULL,
    visitor_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    visited_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.profile_visits OWNER TO postgres;

--
-- Name: profile_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profile_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profile_visits_id_seq OWNER TO postgres;

--
-- Name: profile_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profile_visits_id_seq OWNED BY public.profile_visits.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    display_name text,
    is_admin boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    bio text,
    is_banned boolean DEFAULT false,
    banned_at timestamp with time zone,
    banned_reason text,
    updated_at timestamp with time zone DEFAULT now(),
    gender text,
    sexuality text,
    age integer,
    town text,
    country text,
    photo_url text,
    is_online boolean DEFAULT false,
    last_seen timestamp with time zone DEFAULT now(),
    is_setup boolean DEFAULT false,
    looking_for character varying(100),
    education character varying(100),
    religion character varying(100),
    smoker character varying(50),
    drinker character varying(50),
    city character varying(255),
    phone_number text,
    gallery_urls text[] DEFAULT '{}'::text[],
    consent_ip character varying(50),
    consent_date timestamp without time zone,
    reset_token text,
    reset_token_expires timestamp with time zone,
    credits integer DEFAULT 100,
    referred_by uuid,
    affiliate_balance numeric(10,2) DEFAULT 0.00,
    is_ghost_mode boolean DEFAULT false,
    total_private_messages_sent integer DEFAULT 0,
    total_lobby_messages_sent integer DEFAULT 0,
    height integer,
    weight integer,
    hair_color text,
    eye_color text,
    music_preference character varying(50),
    body_type character varying(50),
    zodiac_sign character varying(50),
    date_of_birth date,
    CONSTRAINT profiles_age_check CHECK ((age >= 18)),
    CONSTRAINT profiles_gender_check CHECK ((gender = ANY (ARRAY['male'::text, 'female'::text, 'other'::text]))),
    CONSTRAINT profiles_sexuality_check CHECK ((sexuality = ANY (ARRAY['heterosexual'::text, 'gay'::text, 'lesbian'::text, 'bisexual'::text, 'other'::text])))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: sent_gifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sent_gifts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    gift_id uuid,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sent_gifts OWNER TO postgres;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    stripe_customer_id text,
    stripe_subscription_id text,
    plan_type text NOT NULL,
    status text NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT subscriptions_plan_type_check CHECK ((plan_type = ANY (ARRAY['daily'::text, 'weekly'::text, 'monthly'::text, 'video_daily'::text, 'video_monthly'::text]))),
    CONSTRAINT subscriptions_status_check CHECK ((status = ANY (ARRAY['active'::text, 'canceled'::text, 'expired'::text])))
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: support_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    status text DEFAULT 'unread'::text
);


ALTER TABLE public.support_messages OWNER TO postgres;

--
-- Name: user_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_blocks (
    id integer NOT NULL,
    blocker_id uuid,
    blocked_id uuid,
    created_at timestamp with time zone DEFAULT now()
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
-- Name: user_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_photos (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    photo_url text NOT NULL,
    is_profile_pic boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    cloudinary_id text
);


ALTER TABLE public.user_photos OWNER TO postgres;

--
-- Name: user_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_photos_id_seq OWNER TO postgres;

--
-- Name: user_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_photos_id_seq OWNED BY public.user_photos.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: chat_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_reports ALTER COLUMN id SET DEFAULT nextval('public.chat_reports_id_seq'::regclass);


--
-- Name: profile_images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_images ALTER COLUMN id SET DEFAULT nextval('public.profile_images_id_seq'::regclass);


--
-- Name: profile_visits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_visits ALTER COLUMN id SET DEFAULT nextval('public.profile_visits_id_seq'::regclass);


--
-- Name: user_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks ALTER COLUMN id SET DEFAULT nextval('public.user_blocks_id_seq'::regclass);


--
-- Name: user_photos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_photos ALTER COLUMN id SET DEFAULT nextval('public.user_photos_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: affiliate_commissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.affiliate_commissions (id, affiliate_id, referred_user_id, amount, manual_payment_id, package_name, created_at) FROM stdin;
\.


--
-- Data for Name: blocked_ips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocked_ips (ip_address, reason, banned_at) FROM stdin;
\.


--
-- Data for Name: chat_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_reports (id, reporter_id, reported_id, reason, message_preview, created_at) FROM stdin;
\.


--
-- Data for Name: drip_campaigns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drip_campaigns (user_id, started_at, last_message_at, next_message_at, message_count, is_active) FROM stdin;
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorites (id, user_id, favorited_user_id, created_at) FROM stdin;
2bc8005a-ff45-4e25-888b-3c8bce31616f	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	2026-02-27 01:32:52.642802+01
fc5726ea-5629-4420-9291-5f586e4804ff	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	935fc335-2d47-4532-87f4-18789f0ff4c2	2026-02-27 01:37:43.747955+01
427f6932-6b4f-406f-ab8b-3ff290db0dde	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d004309a-5267-4af3-8216-3c5504ce5425	2026-03-01 06:39:55.115207+01
114b41e4-8756-4f02-9b91-7d45b58c786e	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	17a3a2a2-6c31-4614-8ea8-464254847786	2026-03-02 08:56:42.331265+01
a2dc3a93-fb51-4e57-b198-b7e439d38f05	8807bf23-53b6-47f4-a6ba-3af774e3cea0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	2026-03-05 03:09:28.272566+01
a90ba567-8219-48be-8ae0-05bbbd8577eb	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	2026-03-05 03:10:00.289279+01
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friends (id, sender_id, receiver_id, status, created_at, updated_at) FROM stdin;
414a4267-f839-430a-a7f9-ee9d25e45942	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d004309a-5267-4af3-8216-3c5504ce5425	pending	2026-03-01 06:39:52.611392+01	2026-03-01 06:39:52.611392+01
\.


--
-- Data for Name: gifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gifts (id, name, icon, cost) FROM stdin;
7a634930-adaf-4b95-84bb-a25a188fc445	Coffee	https://img.icons8.com/color/96/coffee-to-go.png	5
1b606f9b-a6c9-4161-85b5-1bbb17290a16	Rose	https://img.icons8.com/color/96/rose.png	10
1f492164-1c05-4750-bbb6-2a124bf3e81b	Kiss	https://img.icons8.com/color/96/lips.png	15
44465438-cd92-4a50-95e5-7ec08e82af7c	Love Letter	https://img.icons8.com/color/96/love-letter.png	20
a222f7bd-2363-4b89-94a8-399a483fd5bf	Chocolate	https://img.icons8.com/color/96/chocolate-bar.png	30
6ea5684e-10e9-4f8a-8538-de5ad76e2610	Teddy Bear	https://img.icons8.com/color/96/teddy-bear.png	50
37eaf6cc-d1af-489d-a361-2c7aa8bdebca	Cake	https://img.icons8.com/color/96/birthday-cake.png	60
2b70a171-c972-4c27-a2af-ad53f96b7a38	Diamond Ring	https://img.icons8.com/color/96/diamond-ring.png	500
0b7d4b14-cac7-4a00-bd1a-c7b80394cccf	Crown	https://img.icons8.com/color/96/crown.png	1000
63155091-ef70-4f2a-bf87-ec24ba36b578	Private Jet	https://img.icons8.com/color/96/airport.png	5000
71dfe238-65b6-47f5-bd0f-476aabc7bd2c	Romantic Dinner	https://img.icons8.com/color/96/restaurant-table.png	100
1a32038f-9a58-427e-8e4c-ff8793d8cb67	Bouquet	https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f490.png	75
\.


--
-- Data for Name: hidden_chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hidden_chats (user_id, hidden_user_id, hidden_at) FROM stdin;
fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	2026-03-05 02:53:55.803275+01
fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	2026-03-05 02:53:59.100434+01
8807bf23-53b6-47f4-a6ba-3af774e3cea0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	2026-03-05 02:59:24.116688+01
\.


--
-- Data for Name: lobby_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lobby_messages (id, user_id, message, created_at) FROM stdin;
83e5ba71-2bd6-40a1-9e81-46d242a60ebb	8807bf23-53b6-47f4-a6ba-3af774e3cea0	ff	2026-03-02 08:55:44.87207+01
98c76a40-14f4-434e-87cb-26340d6ae787	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	.	2026-03-04 01:52:41.773701+01
69a8d527-07a6-4e30-95f0-5c5692129439	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	🙂	2026-03-04 05:24:23.44398+01
\.


--
-- Data for Name: manual_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.manual_payments (id, user_id, amount, package_name, receipt_url, status, created_at) FROM stdin;
\.


--
-- Data for Name: message_limits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_limits (id, user_id, chat_type, conversation_id, message_count, reset_at, created_at, last_message_at) FROM stdin;
5cdd3c92-abcd-4e17-afc3-324f25534378	8807bf23-53b6-47f4-a6ba-3af774e3cea0	private	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	3	2026-03-01 08:35:09.255704+01	2026-03-01 08:35:09.255704+01	2026-03-01 08:35:09.255704+01
e954e029-06dd-411a-97a0-2cbc896bfe01	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	2	2026-01-22 12:46:07.897807+01	2026-01-22 12:46:07.897807+01	2026-01-22 12:48:11.760501+01
a1c94cdd-f129-4a18-8e43-c242b08a4ad5	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	d4e1d5c4-1864-4671-9bd0-95a39bd82ed6-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	2	2026-02-22 12:48:18.406534+01	2026-02-13 07:13:53.446257+01	2026-02-13 07:13:53.446257+01
7ab3ab41-25ee-4556-8db9-b6876404b93b	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	f23685c7-29af-4fa6-a3dd-e282aaac9640-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1	2026-02-11 06:59:25.190172+01	2026-02-11 06:59:25.190172+01	2026-02-11 06:59:25.190172+01
d0a1b099-8098-4625-8d55-e188a054c1cb	8807bf23-53b6-47f4-a6ba-3af774e3cea0	lobby	\N	1	2026-03-02 08:55:44.89192+01	2026-03-02 08:55:44.89192+01	2026-03-02 08:55:44.89192+01
d47b87d8-4632-4da8-ab5c-5f52ee69e56d	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	5157ac77-1580-4cdb-94ba-0778279c53b9-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1	2026-02-23 16:35:30.547156+01	2026-02-13 07:32:43.326177+01	2026-02-13 07:32:43.326177+01
3d5701e3-7333-4c46-90c9-fd3ca28911a1	8807bf23-53b6-47f4-a6ba-3af774e3cea0	private	54420f72-9673-404c-a976-61b45320c4af-8807bf23-53b6-47f4-a6ba-3af774e3cea0	0	2026-03-02 08:55:54.806013+01	2026-03-02 08:55:54.806013+01	2026-03-02 08:55:54.806013+01
e3076d2c-49a3-4ada-a8e1-0325adfd5785	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 06:27:28.90698+01	2026-02-15 06:27:28.90698+01	2026-02-15 06:27:28.90698+01
e90d294b-efff-4a95-8bb1-c46d317b4f27	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-03-04 01:52:41.812003+01	2026-03-04 01:52:41.812003+01	2026-03-04 01:52:41.812003+01
5138ac13-9697-470c-abac-c4ec8079d158	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 13:52:54.882849+01	2026-02-15 13:52:54.882849+01	2026-02-15 13:52:54.882849+01
60d570b4-0c98-4f7c-9c73-d40ef3c37cae	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 13:24:30.063177+01	2026-01-22 13:24:30.063177+01	2026-01-22 13:24:30.063177+01
2d4a54fb-bab4-4730-a49f-65e5ab53ebc0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 13:25:01.797023+01	2026-01-22 13:25:01.797023+01	2026-01-22 13:25:01.797023+01
9717bf36-6dd8-4a91-ada0-a2efe400f4ba	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 13:25:14.664487+01	2026-01-22 13:25:14.664487+01	2026-01-22 13:25:14.664487+01
69ece640-aaa7-461b-980c-b8b83ea9bf35	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	d004309a-5267-4af3-8216-3c5504ce5425-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1	2026-03-01 05:55:51.878784+01	2026-03-01 05:55:51.878784+01	2026-03-01 05:55:51.878784+01
71325b4c-8872-4e10-ae1d-4ab6936fa2a0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-22 21:21:49.152893+01	2026-02-22 21:21:49.152893+01	2026-02-22 21:21:49.152893+01
e1f8169f-be38-45ec-8e99-043bab485bca	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 14:28:27.360916+01	2026-01-22 14:28:27.360916+01	2026-01-22 14:28:27.360916+01
75e27a0d-aad9-4c31-87b0-e937513aeb0e	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 15:23:52.863916+01	2026-01-22 15:23:52.863916+01	2026-01-22 15:23:52.863916+01
2836ad1a-f7e0-41a1-a390-35762891e12a	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 13:31:01.099479+01	2026-01-22 13:31:01.099479+01	2026-01-22 13:31:01.099479+01
9d1aaa8f-502e-48cc-a699-232e591f6f8d	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 14:55:13.725086+01	2026-01-22 14:55:13.725086+01	2026-01-22 14:55:13.725086+01
a2602b0c-0ee1-4a6c-9d1e-0bd985cf0b40	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	80634134-6662-452b-be5f-3541ad7cc9ec-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-02-11 07:23:06.332784+01	2026-02-11 07:23:06.332784+01	2026-02-11 07:23:06.332784+01
586064e2-4d39-4147-8f27-108575328207	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 13:45:09.83352+01	2026-01-22 13:45:09.83352+01	2026-01-22 13:45:09.83352+01
f8ff4438-6f21-47a6-9a43-d9d1dcad0add	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 15:24:29.581869+01	2026-01-22 15:24:29.581869+01	2026-01-22 15:24:29.581869+01
c7f06ccd-cfda-410b-a7fc-b7cf41aab8ad	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	7	2026-03-01 08:23:18.823731+01	2026-02-20 20:58:47.185273+01	2026-02-20 20:58:47.185273+01
c95eac57-b229-49ff-b0c9-bc78bb970123	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 15:07:04.208119+01	2026-01-22 15:07:04.208119+01	2026-01-22 15:07:04.208119+01
7210fbd6-2a7c-4628-ae2d-2f94eda5ec8c	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-17 07:36:52.542653+01	2026-02-17 07:36:52.542653+01	2026-02-17 07:36:52.542653+01
61a99bc6-6748-44b1-99b8-68da9780b929	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 14:34:14.165824+01	2026-01-22 14:34:14.165824+01	2026-01-22 14:34:14.165824+01
f6f54aba-8cb9-4011-9607-b5af0b3b3955	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 15:14:41.646936+01	2026-01-22 15:14:41.646936+01	2026-01-22 15:14:41.646936+01
4ed3c567-cd46-467e-9c52-009734924f51	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	3e5b5df3-150b-4e75-9d1e-e69eff5d4a33-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1	2026-02-11 03:46:27.312071+01	2026-02-11 03:46:27.312071+01	2026-02-11 03:46:27.312071+01
52c64166-e214-4253-ae45-ab0613f250c1	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-10 00:04:39.961737+01	2026-02-10 00:04:39.961737+01	2026-02-10 00:04:39.961737+01
25c5f421-3b8f-4009-b5b6-71fd62b97078	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 14:21:37.543767+01	2026-01-22 14:21:37.543767+01	2026-01-22 14:21:37.543767+01
f27ecc50-149b-4748-83a9-6b4867db6911	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-18 15:29:36.792715+01	2026-02-18 15:29:36.792715+01	2026-02-18 15:29:36.792715+01
6e74b1a6-69ed-4f60-a73c-9371fd04216c	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 09:47:57.028826+01	2026-02-19 09:47:57.028826+01	2026-02-19 09:47:57.028826+01
94c20e4d-a112-4374-88e7-e56c12f1ff36	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 09:48:19.984139+01	2026-02-19 09:48:19.984139+01	2026-02-19 09:48:19.984139+01
86b618ee-d590-4803-9910-6113a46e8f42	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	1230acac-7210-49d2-8323-27b7c0c31bbf-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1	2026-02-11 06:59:14.943157+01	2026-02-11 06:59:14.943157+01	2026-02-11 06:59:14.943157+01
b76666d8-c96e-4302-a428-fae6e7b06a69	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	2489129e-b6e1-4664-a92f-745dd7c23bb9-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	2	2026-02-22 21:22:16.254011+01	2026-02-08 09:25:10.466275+01	2026-02-08 09:25:10.466275+01
f7b934b3-6987-41dd-b519-a97f032e0b05	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-12 22:11:34.941664+01	2026-02-12 22:11:34.941664+01	2026-02-12 22:11:34.941664+01
4e91bf4b-9078-474a-8116-5e3b63096a6d	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 16:08:52.177927+01	2026-01-22 16:08:52.177927+01	2026-01-22 16:08:52.177927+01
259bb572-f2db-4606-b01a-f2bc0ee8cd7d	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 16:08:54.164957+01	2026-01-22 16:08:54.164957+01	2026-01-22 16:08:54.164957+01
101d79a5-22ed-46dc-a878-718c3050714b	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 16:08:55.681542+01	2026-01-22 16:08:55.681542+01	2026-01-22 16:08:55.681542+01
0aa36cec-8c31-4bd8-967e-7c47d5125749	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58-ff029dce-a344-4eb3-a814-43481cc7e6af	4	2026-02-09 00:43:19.805653+01	2026-02-09 00:43:19.805653+01	2026-02-09 00:43:19.805653+01
0dd82436-3be3-498f-84ca-43bc04a47a95	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 09:17:07.838565+01	2026-02-15 09:17:07.838565+01	2026-02-15 09:17:07.838565+01
e350c896-7c30-43da-8846-b8e193482631	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 13:53:30.573364+01	2026-02-15 13:53:30.573364+01	2026-02-15 13:53:30.573364+01
958eb770-8881-46a8-9302-432529327123	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	aeaf124d-20bc-43d2-8c97-59181baf57e1-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	4	2026-02-22 12:52:51.646731+01	2026-02-22 12:52:51.646731+01	2026-02-22 12:52:51.646731+01
238d8f63-b158-46f0-8baa-0b2478f94b59	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	17f90d33-1e7e-4866-b226-e1344eb8b2ee-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-02-16 17:03:01.399052+01	2026-02-09 00:30:54.77828+01	2026-02-09 00:30:54.77828+01
e3bc8c46-0c42-42cf-847f-37279af2859f	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-14 07:44:01.675322+01	2026-02-14 07:44:01.675322+01	2026-02-14 07:44:01.675322+01
7996d170-b28a-4924-8359-2a5da9a02889	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-13 08:14:40.067508+01	2026-02-13 08:14:40.067508+01	2026-02-13 08:14:40.067508+01
1eb7e77d-faa3-4098-9a35-9a2c826b975e	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	6	2026-03-08 08:22:02.649724+01	2026-03-01 08:22:02.649724+01	2026-03-01 08:22:02.649724+01
70bccc81-fefe-49e0-a9d2-5acf72768943	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	4ede5d1d-fea1-44a7-9899-fc89bf583499-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-03-04 04:06:27.321315+01	2026-02-10 05:55:38.969817+01	2026-02-10 05:55:38.969817+01
1fee3592-9e2c-4746-ab51-d1e3921033bd	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-03-04 05:24:23.465476+01	2026-03-04 05:24:23.465476+01	2026-03-04 05:24:23.465476+01
f020783e-e7be-44a5-904a-c7f29f743fc3	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58-fd450aea-b2e5-447c-8169-8a07a6db4afd	4	2026-02-11 07:04:00.111379+01	2026-02-11 07:04:00.111379+01	2026-02-11 07:04:00.111379+01
117e0782-53dc-45c4-b756-d4faff652fb8	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	935fc335-2d47-4532-87f4-18789f0ff4c2-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-03-05 02:56:07.260854+01	2026-02-23 16:46:29.744861+01	2026-02-23 16:46:29.744861+01
0df23bb6-50ce-4150-bf0e-faf2d54e9356	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-17 15:32:20.360206+01	2026-02-17 15:32:20.360206+01	2026-02-17 15:32:20.360206+01
76d7e51c-2462-42ad-a914-44ad7f8495c1	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-13 07:20:39.989549+01	2026-02-13 07:20:39.989549+01	2026-02-13 07:20:39.989549+01
b4fdcd3c-1ab4-4d94-b012-de6e13e8bd15	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 17:14:49.831566+01	2026-01-22 17:14:49.831566+01	2026-01-22 17:14:49.831566+01
57655dba-0554-451f-a94b-4e2de038b7ef	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-22 19:08:41.00479+01	2026-01-22 19:08:41.00479+01	2026-01-22 19:08:41.00479+01
46df1cc4-16f5-4ab7-b530-dbe76e5e8af4	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	61f0b629-b6ee-4104-8f70-54ac4abeb06b-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	4	2026-02-19 04:00:11.895048+01	2026-02-19 04:00:11.895048+01	2026-02-19 04:00:11.895048+01
f7c013c4-b15e-4347-828c-adf27137775e	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-20 06:22:52.011335+01	2026-02-20 06:22:52.011335+01	2026-02-20 06:22:52.011335+01
e9bc5a00-3634-4aeb-938b-bd4e9244ec3e	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 03:59:43.91582+01	2026-02-19 03:59:43.91582+01	2026-02-19 03:59:43.91582+01
f509b5fd-068f-40a9-abde-ea6e52ad9ece	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-01-31 22:19:49.109818+01	2026-01-31 22:19:49.109818+01	2026-01-31 22:19:49.109818+01
79b817c7-2010-4510-98b5-7b96f76ab650	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	4ffb9ae9-2ef9-4197-9680-b0ae8599ce09-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-02-08 07:07:15.837092+01	2026-02-08 07:07:15.837092+01	2026-02-08 07:07:15.837092+01
a6c6d7c5-63f0-4d9c-87cf-e2e5a93eb23d	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-11 06:59:07.751664+01	2026-02-11 06:59:07.751664+01	2026-02-11 06:59:07.751664+01
17a80d92-a608-4632-9c36-6cb739cdef64	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-11 07:04:29.514353+01	2026-02-11 07:04:29.514353+01	2026-02-11 07:04:29.514353+01
795954d4-5f81-483a-a115-9d5bbf863168	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 13:52:10.36343+01	2026-02-15 13:52:10.36343+01	2026-02-15 13:52:10.36343+01
a02c2730-fb3c-4c62-9522-703598872efa	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-15 13:52:13.441996+01	2026-02-15 13:52:13.441996+01	2026-02-15 13:52:13.441996+01
36c5b50d-5098-485c-b7dc-e0c3c26b0dc7	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-18 10:11:59.280773+01	2026-02-18 10:11:59.280773+01	2026-02-18 10:11:59.280773+01
f01166ff-7574-4311-9dad-ed1246797b0a	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 09:47:12.497909+01	2026-02-19 09:47:12.497909+01	2026-02-19 09:47:12.497909+01
875df678-2b99-4044-ab94-fd210da77afd	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 09:47:30.749673+01	2026-02-19 09:47:30.749673+01	2026-02-19 09:47:30.749673+01
c1921bb7-a764-433d-a258-7147a9c66c35	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-19 09:48:27.063978+01	2026-02-19 09:48:27.063978+01	2026-02-19 09:48:27.063978+01
42a57048-d6ba-4270-8b5b-cd3becaab218	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-02 02:30:14.013763+01	2026-02-02 02:30:14.013763+01	2026-02-02 02:30:14.013763+01
cd89e39a-6fc8-44b1-bb4e-f7adc81a2e6c	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-02 02:30:22.553932+01	2026-02-02 02:30:22.553932+01	2026-02-02 02:30:22.553932+01
6a24bf9c-2c73-4a99-a87f-8e88a7071292	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-02 02:31:39.700967+01	2026-02-02 02:31:39.700967+01	2026-02-02 02:31:39.700967+01
efbd0c70-aaa9-4ac5-be2b-47f16e0a4291	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-22 21:21:13.668915+01	2026-02-22 21:21:13.668915+01	2026-02-22 21:21:13.668915+01
ca889498-2f87-44ef-88d2-d2fb7bc91327	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	66eb3e5b-dcb6-4ce6-b64e-b2b7fcbd9270-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-02-16 18:08:03.690789+01	2026-02-16 18:08:03.690789+01	2026-02-16 18:08:03.690789+01
ac475014-b89e-4023-a881-b3cd37be8ff9	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	565d9fbd-4638-48c9-9845-9e18ad10db67-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	10	2026-02-11 07:07:07.984187+01	2026-02-11 07:07:07.984187+01	2026-02-11 07:07:07.984187+01
74652012-aaa8-4a65-b41c-22bcd69600d0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-12 09:37:34.165934+01	2026-02-12 09:37:34.165934+01	2026-02-12 09:37:34.165934+01
429ec329-bd33-4955-b807-990c352649ed	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-06 01:08:05.655573+01	2026-02-06 01:08:05.655573+01	2026-02-06 01:08:05.655573+01
579fc704-66af-4bb1-a531-3f44be7ccf69	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-07 04:39:13.301619+01	2026-02-07 04:39:13.301619+01	2026-02-07 04:39:13.301619+01
4c761ed8-e541-49cd-8fe5-fd84359104f3	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-09 00:30:50.466838+01	2026-02-09 00:30:50.466838+01	2026-02-09 00:30:50.466838+01
9daffc1d-e85f-470d-a257-1343a36f4030	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	f35e090d-d8a0-437c-aae1-1735b9eb48cc-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0	2026-03-04 05:25:02.621709+01	2026-03-04 05:25:02.621709+01	2026-03-04 05:25:02.621709+01
948c34ed-993f-4a0b-873b-7bbc91b1839b	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	private	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	530	2026-03-08 08:35:00.35541+01	2026-03-01 08:35:00.35541+01	2026-03-01 08:35:00.35541+01
dfb6beb6-93e0-49d3-8206-841d61b5db25	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-13 07:22:14.476319+01	2026-02-13 07:22:14.476319+01	2026-02-13 07:22:14.476319+01
4bd97c32-db50-45e9-b721-ce13c4fd1823	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	lobby	\N	1	2026-02-13 07:23:09.019028+01	2026-02-13 07:23:09.019028+01	2026-02-13 07:23:09.019028+01
\.


--
-- Data for Name: payout_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payout_requests (id, user_id, amount, payment_details, status, created_at) FROM stdin;
\.


--
-- Data for Name: private_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.private_messages (id, conversation_id, sender_id, receiver_id, message, created_at, is_read) FROM stdin;
02f0fb2a-25d3-4ea8-ae13-57b7a38403c8	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	ggg	2026-02-27 01:33:11.308699+01	f
8e1af334-ef7a-43ac-afb2-188791ecd248	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	fff	2026-02-27 03:27:33.999191+01	f
8e7e8213-7237-4a0f-984c-e6bfa70c69eb	d004309a-5267-4af3-8216-3c5504ce5425-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d004309a-5267-4af3-8216-3c5504ce5425	ff	2026-03-01 06:40:18.845735+01	f
6ed50a54-fad7-4445-9a56-eb0d570950ae	935fc335-2d47-4532-87f4-18789f0ff4c2-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	935fc335-2d47-4532-87f4-18789f0ff4c2	📞 Video call attempt...	2026-03-01 07:20:19.205193+01	f
05f0ea59-32f7-455a-b1ec-034d2211c918	935fc335-2d47-4532-87f4-18789f0ff4c2-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	935fc335-2d47-4532-87f4-18789f0ff4c2	📞 Voice call attempt	2026-03-01 07:53:02.275304+01	f
432c5e53-0d12-406d-9964-da69cd169865	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	📞 Voice call attempt	2026-03-01 08:22:02.649724+01	f
41cb3255-a477-4425-a3bd-b74aa8938bc4	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	📞 Voice call attempt	2026-03-01 08:22:14.189136+01	f
527586b1-2c57-4088-bd24-ce70b9087786	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	📞 Voice call attempt	2026-03-01 08:22:26.583416+01	f
954d5934-d1c4-4494-99f9-5b8c999769d5	565d9fbd-4638-48c9-9845-9e18ad10db67-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	565d9fbd-4638-48c9-9845-9e18ad10db67	📞 Voice call attempt	2026-03-01 08:22:40.036139+01	f
772769d3-061d-43ce-b9f3-20dd59ef9cea	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	📞 Voice call attempt	2026-03-01 08:24:43.585134+01	f
1c03b891-1702-468a-b3da-e14d64b80a82	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	📞 Voice call attempt	2026-03-01 08:24:54.435008+01	f
0793c2d9-7981-478b-9280-788a349abac9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 02:57:49.185645+01	t
825af0da-f288-4e4c-ad30-ebfe8fe97e0a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:08:06.353453+01	t
d8e2e60d-e96d-40da-b6ca-f8f07e71c45e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:08:20.862886+01	t
69682002-2f12-4352-b579-b24dade5cf8c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:08:29.982967+01	t
cc08d529-8a74-4a0d-b099-14345bff0b01	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:21:50.249224+01	t
8e785062-25ed-4816-812c-7f5c4bb053a8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:22:01.493798+01	t
e781527d-b405-408a-882b-86308ebbb609	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:22:04.963989+01	t
0e492068-6384-414f-af2a-568215d2af3d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:32:04.08105+01	t
ae1e93da-3b49-4106-b4a8-b84e2524f5b4	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	📞 Voice call attempt	2026-03-01 09:09:25.431131+01	f
aaee8385-3479-4939-9f66-1187ea34efe7	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	🎥 Video call attempt	2026-03-01 09:09:37.114528+01	f
4f6ec92f-0d0b-47a3-8294-e31e1c701c46	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:44:46.710339+01	t
b1c01843-5f37-4905-a033-61d3496bb268	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:44:56.379874+01	t
46d3cd7e-b534-4055-ac03-7d2370bdb1d3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:16:48.474031+01	t
bd87e235-be11-41a4-b14f-4bdf1908bc5a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:16:55.938483+01	t
d5a88e39-a13f-45b8-9687-0c5913a11710	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:33:47.20316+01	t
8230c4f1-4084-4cff-8273-61041b3fc73a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:06.724332+01	t
d7e34f44-e329-42cc-a621-fa911e61d334	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:09.92638+01	t
6cf4937a-9909-4175-83e4-ed3d75b63888	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:11.623525+01	t
ede17cf9-f5a2-42e3-8ce4-6b9801109c6a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:11.778704+01	t
5a159142-d15e-4a34-980b-fdefcaa3f1ea	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:12.553806+01	t
fce04ab6-e1a1-4308-af5f-bc1c4ce15564	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:12.778621+01	t
d483ef0c-24c8-40c5-9f26-acbf45d5f3c4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:12.921433+01	t
b91464cc-ea2f-47a5-921f-8dad0e2c0d3e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 04:41:02.732973+01	t
2da03c77-1c04-475a-9075-74e2d4957d81	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 04:41:36.740224+01	t
4e0c004e-afb1-4415-97c3-11e35a946b4c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:12:06.227297+01	t
e7f37d23-3472-4bd2-90c2-dab44bd9236f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:31:57.789778+01	t
d9e8b807-1be3-484b-aa5b-08f69bdbc8d5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:38:10.081688+01	t
20175e21-b2be-49cb-b6cd-c8ba1e0b9d04	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:52.49141+01	t
062d40ee-308f-4892-8d96-0ca9107ac669	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 05:44:04.217178+01	t
8e86eab7-69d3-43b4-a9e2-da500210e5f9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:01:02.367172+01	t
91da0cc5-5182-463e-88b6-6e971b3c8e42	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:01:10.917906+01	t
9bf6df62-ac78-44cc-9aff-779bfe5d7db5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:01:15.843002+01	t
63a283ef-1627-48dc-93c6-42c9e1a5d61f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:01:45.747071+01	t
ea5036e2-e6eb-4cac-968c-476f70605e07	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:09:16.695091+01	t
ef6728e9-232b-4ae1-b74b-220ef6d3a169	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:23:38.200433+01	t
09324289-8d08-4d9e-876a-a63a891424fa	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:33:27.712847+01	t
d64d14c5-bdd0-4688-8bed-03d417055860	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:46:40.151124+01	t
22f26d28-b1e5-4804-9ed8-330f70f388d8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:19.612474+01	t
eab39361-53d4-4b09-ae20-4ec63804dfd6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:20.758177+01	t
6609e76f-767d-49f2-9312-892bcd376e09	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:21.296789+01	t
1de00bb3-101a-4d7e-89f2-2ff04553d335	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:21.527729+01	t
17895b2c-f038-4af8-98e2-d2e158a16411	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:21.626123+01	t
57684e94-937e-452d-959a-bb5924d159d3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:21.801855+01	t
c8b9d2fc-1708-402b-9e35-b6e7b71452be	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:22.558425+01	t
45caadc7-4e8b-4d41-a632-f3795bdbb3b7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:23.309051+01	t
1a198db1-e238-4cd5-85ed-4ea9a739d602	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:24.100765+01	t
0fcce1e6-39e3-46f8-80d5-0e6718d75c19	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:24.952328+01	t
f01d8935-0cf6-48d0-9bf9-bb275c60232d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:25.022798+01	t
127d5318-f9d1-4a72-aa5d-2fc3c58b3415	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:25.218698+01	t
04854789-0bb9-43c8-940d-6eed1821eaf6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:25.795235+01	t
0f97a33d-2a08-4e9b-9f1b-7dcc192b77e7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:26.445355+01	t
c7f723e3-1d0e-4c25-a908-189a4505560c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:01:26.498909+01	t
f20d9ed1-3758-48a1-8878-d25a9c38e95f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:01:38.64037+01	t
906a481c-c185-43f6-ad84-1384b15aa756	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:09:29.47521+01	t
98581d47-40a9-4575-86ad-d87fecdf602e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:09:42.398955+01	t
644606ba-8b59-45ac-9763-f0237cfd1cdf	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:23:44.812228+01	t
5ee7bc2e-76e0-4a6f-92ec-7a3249a93f68	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:33:37.160257+01	t
e6f12716-e8de-4111-98d6-45d9980145eb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:33:43.069185+01	t
199e551c-c6fe-42d8-998a-2c5dcb239b04	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:56:25.729875+01	t
95857577-0c14-46f4-8f39-cb324b6c8a91	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:13.548393+01	t
fa423274-c2dc-4df7-a1f7-9351768bf291	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:13.686043+01	t
b3f3bceb-59a9-46fd-8fe6-c98b5d877ff2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:26.60068+01	t
b8e23efb-b11e-4a6a-94f0-61c78783fb9f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:27.053336+01	t
4b23b763-eb34-42ef-b3d5-1f73933e72df	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:27.226417+01	t
5c48121f-0c01-4e00-9585-c1cf0c1dd626	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:27.395561+01	t
99fd6ba6-3244-4cd2-bb9f-68f44f74083a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:20:27.595524+01	t
c1268978-16f7-456a-ad64-49b240fdd0af	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:25.330147+01	t
226b5d11-b390-4769-967a-97d2491f0d72	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:28.951683+01	t
ed885856-6762-4fbb-abbf-fedf32489be6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:30.166437+01	t
63680111-eb90-4a96-8e8a-055b691c6546	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:30.431447+01	t
936de16b-e66a-473d-9290-12d76035d1c0	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:30.631784+01	t
a7def315-d993-4a0b-a236-6cdc425afa6f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:30.820609+01	t
49a53fc5-a8ba-41db-a066-b4e52b371fd2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:31.041308+01	t
3440d854-cbaa-4aa3-9307-abf13a942eb2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:31.231141+01	t
ac923a11-f722-47e4-be9d-286641c2e33f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:31.445153+01	t
894738c8-ee61-475f-b553-1eea461c49e5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:31.727597+01	t
e6b0976a-0684-47a8-844a-512385fd17ec	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:31.944616+01	t
8d270825-d52b-418c-a772-93a5aae2160c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:32.159296+01	t
19df48c3-b929-4d6d-bb30-9bae2cb3004b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:32.348061+01	t
b886a2fc-1fc9-4a14-88c5-9a039dc83ba5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:32.538557+01	t
cef86f84-33ea-492e-b888-ff505113f73c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:32.721728+01	t
aebfca8f-24c3-4b2d-8ffa-5911ee8de72e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:32.926511+01	t
c25b37ca-308d-4a77-b49e-d9b1b3a0a74c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:33.128359+01	t
633a8622-6339-415f-8ef5-f211dcb9c65d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:03:35.292553+01	t
348649cf-02b0-47f4-bc9a-bb7b201a9f4d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:04:13.772074+01	t
d1d8ba6b-473c-46c7-8c27-1211ab149e21	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:04:22.058977+01	t
c4a6dcb2-80f7-4d5e-baaa-57c9af941981	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:12:42.645267+01	t
5e96b28a-5146-4175-b0f9-38d322a88d38	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:12:52.944544+01	t
4ee7528f-b4f0-45be-b678-6fff9e3affc6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:13:00.624543+01	t
d689a854-c951-47e7-a59b-eb857be89245	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:25:46.94031+01	t
d7469836-8b39-4b46-95bb-ff7d63462055	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:25:54.533899+01	t
2fad62d8-6e67-4199-80f2-539a414a5030	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:35:09.25891+01	t
7f88668c-98e9-4cff-87f4-b07eabfa88de	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:35:16.824292+01	t
b8e5ac2a-392a-4679-9f0d-f30daa7caf02	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:56:47.037936+01	t
a9c6921a-1c13-454f-9ad1-00d2d3fdb763	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:57:00.880191+01	t
558d750e-756c-49df-8762-fa57c04db7c3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:21:42.609878+01	t
6d78d43f-dd87-4c6e-9862-ecf345ade5bb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:33.313257+01	t
135f0026-bb59-4793-84ba-6c2db4144e26	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:33.515152+01	t
4dec9e6e-00a5-4d26-94a2-bb3027466425	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:33.698881+01	t
d0bcd102-708f-4570-b83c-8fab2a4a1e47	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:37.075289+01	t
324ef025-bf39-4e6f-9218-a9e5152ef59c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:37.293255+01	t
56a5a049-19c5-40cb-a41b-d0fb860c276a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:37.511155+01	t
98e6f633-8aea-44f2-9fa0-d8f702595008	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:37.698096+01	t
242b1654-55c3-4975-a36e-6f24c665da92	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:38.974047+01	t
b7884c66-5ef0-4c09-93b4-4a95c9f5e508	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:18:45.24188+01	t
24dca0f8-66c5-4ac3-9fba-af6cb2585b2c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:19:07.036272+01	t
3440a68a-f5bc-4841-b16d-716a29f9d7b5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:19:20.130752+01	t
347bed79-d9ec-454d-8eee-85d02cbecb54	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:45.857418+01	t
6432da93-2f28-4950-b003-a02b4843d3ad	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:46.374579+01	t
9ef0205a-0ef9-4f4b-80c5-31725bc66500	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:00:46.574735+01	t
5cdf95af-0275-4485-82e8-2b29d31f5f0f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:19:33.166542+01	t
cbff50d6-b7ea-480c-a204-5d53d1c8f004	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:32:35.609762+01	t
92e8dcef-36ec-41cc-8120-00c46e61afb3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:33:06.976755+01	t
5a3b30e6-b639-413b-b9eb-db9bc0139b49	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:29.436623+01	t
1e600ab0-3ba1-4bce-9c91-481ba1bc94d0	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:34.248745+01	t
bde1d5d7-4fbf-4b03-8902-0883e100be07	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:56:04.868224+01	t
0304522d-848b-4a3c-9c27-1d1bf35b69fe	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:56:14.828543+01	t
14405a5d-1f8d-4ba9-8911-1da0ef4890f4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:45:50.067019+01	t
aaf3eb82-0750-44c4-a990-7d03c271d8eb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:46:05.328207+01	t
e803ec07-72ca-48bb-b1c1-d052aa4f14cd	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:57:14.232523+01	t
aadbec2a-88c3-4f2e-869f-7118117eda14	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:05:36.216376+01	t
2c8e4dea-453e-4a80-a162-4766a1981f2f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:05:41.212822+01	t
027d5209-78d0-43da-8780-b148ae420a95	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:05:53.518146+01	t
5ee6d33f-4e78-4d53-9611-747f7586c75b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:17:53.445744+01	t
dbe7d126-aeb4-4d39-9b7f-9d9c809ab793	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:27:46.430209+01	t
e16319d2-f210-42ce-87a3-da7397af5bfd	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:27:53.970897+01	t
ba56aa62-9c50-426b-b02b-8408ea80045b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:28:10.921571+01	t
d8440f13-09c3-4e48-9616-9f1e91816dc1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:36:19.687261+01	t
2fc83840-687c-4177-accf-316d8d503b19	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:36:25.541127+01	t
c0fa0730-2f02-41a5-9ed3-ac37200d9dda	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:36:30.170827+01	t
e6688d09-f048-415e-91f8-a48cfdcd80ca	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:36:37.528699+01	t
419d600a-c743-4e2c-a918-41b4fd8af8e9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:36:41.46587+01	t
af166109-9f25-45c0-8a9b-096e26ea8278	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 04:06:25.955149+01	t
b007d890-eb19-4b5a-b57d-dc1174c0ae84	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:06:54.658858+01	t
355a61bb-aac0-4736-82a6-30ab61e04e64	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:07:02.517879+01	t
ca86f645-3be9-4a2c-b113-e59cc2138374	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 04:07:10.815526+01	t
1084c233-fd5c-4637-a160-c89f7059df77	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:19.854291+01	t
bcd096f5-d4ef-4848-b921-63663cb27b9d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:21.30592+01	t
19df24d1-6306-4b0f-b4d4-e5c6b892e705	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:22.120935+01	t
5aff866d-b754-4195-bc4e-c3f8a2011332	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:22.768057+01	t
d3da98a8-150a-4231-936b-6c33fcf918f5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:23.492058+01	t
568112ac-cd66-497e-8abe-8c711a84c12b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:44.242238+01	t
1e9e1390-dca2-4e1b-a0f2-ba9869de2ba7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:47.10352+01	t
5aba00ac-280d-4c94-b783-ccdcb75aa0f4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:47.47054+01	t
95653bf7-61d7-448e-95b5-8e41578737ba	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:47.689371+01	t
93224c58-0fdb-457d-ae12-257ee755f10b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:47.880594+01	t
74a0a49e-cad9-4770-adb0-1054f464c545	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:48.082787+01	t
f3d2b6e1-5c34-41c6-a8c7-f9ffae7607a4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:48.224723+01	t
b243c234-c1cc-4ee6-aac1-0e02da4b4bab	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:19:55.911799+01	t
b5909686-5039-43ca-af43-bea99257d53e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	ggg	2026-03-02 05:36:55.708596+01	t
388aa48f-d968-44cb-b45d-83ec5b371658	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:12.952209+01	t
347e78e0-ddd6-4880-b45d-dbc800ada8db	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:13.372023+01	t
af637a75-538a-40b8-8ec4-1828ea7604b6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:13.535226+01	t
92338c27-2b68-4dba-8f6e-347752c896d8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:13.971928+01	t
ae17d821-bc0d-4f7d-bbfa-163f2ce6cd63	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:14.297516+01	t
a7338fcb-73f0-4f2e-9629-7a674c823c15	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:47.804365+01	t
f63467da-f084-4851-bc02-4c0b3f3282df	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:14.706278+01	t
e6f02656-8dba-4e0e-a6eb-656c184c6f84	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	Vg	2026-03-02 02:57:09.03836+01	t
33ecf815-b899-4e8a-a051-948bf7fd5f2f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:06:05.155688+01	t
72fffbb8-0206-41e5-8aaf-26e70fabb896	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:19:12.263533+01	t
619fdf8e-ce68-40af-bc31-6565f906290d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:30:37.971656+01	t
68073bfe-b4db-49a8-a44a-69ce3cadf32f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:30:45.084955+01	t
8394c6d5-c7aa-49c1-9481-dd47c12d26be	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:42:29.827302+01	t
cb2f1a63-3785-4b99-89c0-370ed58c9d63	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Voice call attempt	2026-03-02 03:42:38.558758+01	t
f73b89db-0ec9-4b55-a13c-f60d8ad3551d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 03:42:47.997787+01	t
d929c0eb-7cd5-48e0-8ac5-73a0ba692184	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:15:20.400475+01	t
c7bcd804-75b2-421b-8bf1-5c0aec1bb1ce	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:15:37.281536+01	t
d7769bc7-1e1d-424e-b588-87fb6f629b0b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:16:10.18365+01	t
d79f9602-0ee6-4f4c-9715-2b2ec393372c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:23.495038+01	t
abb16444-7287-4af3-9996-89c40185ce2e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:23.568836+01	t
fcee5f7d-230e-408d-be05-e283fbcc7f4b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:23.728904+01	t
f8e647fb-f5dd-4391-b8c1-89ddfe5596fb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:23.921002+01	t
6969f576-3bf9-46ac-a31d-93809f98f85e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.079542+01	t
7f60fbac-c816-48c6-ab8a-3da83409a873	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.248748+01	t
efe30f30-328c-48e3-9fc1-b77288d52d04	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.357855+01	t
b3279fdd-ac1a-445f-ab31-9f43cf46b5a8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.469949+01	t
8e413078-a2ec-4996-9f37-e49d4c89625e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.654314+01	t
01da28f2-d5e7-4ad5-bc1d-bdd5d2b5f47d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:24.829397+01	t
416d8b50-fbce-4606-8656-61264f3a7c95	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:25.012747+01	t
c4474af3-a0a2-4b08-9a1a-0ecc7aa69289	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:25.168915+01	t
5f58b129-7dbf-4f49-93a9-520d0fc47590	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:25.400433+01	t
22671b8e-b185-4b6d-8676-2691c49d4368	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:25.823952+01	t
b53a3b3e-e974-4673-897f-b503cb37e214	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 04:22:25.979186+01	t
5df00484-d5ef-4342-ab3c-1bcd7817ea44	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:05:56.560354+01	t
e57ce198-7c8f-4e50-8135-ef8707485c83	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:23:09.546075+01	t
9572799e-1132-4e6a-9682-857e69ef2880	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:23:29.404669+01	t
c1ff62e9-d768-486f-9ada-5e743495e14b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:37:48.426179+01	t
9f574048-62dc-4a2b-86b9-4c7203d231b2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:49.294336+01	t
d0f1153a-3d7e-4988-8e3e-62b782d6b9cd	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:49.879525+01	t
bd8099d1-aede-4079-adbc-bf21bf046cab	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:50.108885+01	t
19059327-282c-4d69-8931-b1a7711c8ead	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:50.197756+01	t
437d00aa-a63f-4200-a62c-2c3f280227b4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:50.48768+01	t
34de574a-f4cd-4b38-aa60-f1c4ea6f054f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:52.147856+01	t
5c356c6c-3239-4cc5-aa26-e71b939e8a50	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:42:52.335394+01	t
f905f7ae-bfb2-4e03-adf8-afe26995628d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:58:31.376123+01	t
4d0af9d0-02c9-43cb-9939-eeb566eebd50	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:58:47.311102+01	t
4efc0719-01de-4104-a8ee-5d519b60b747	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:58:54.926802+01	t
da9579aa-0a0c-4179-8a4c-7360d63fd9df	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 05:59:40.769215+01	t
e078dc12-8cff-49b5-bddc-f2274294ad2b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:00:36.564896+01	t
55b81953-d0f2-45a0-b48f-c9f8fc2e4bad	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:02:31.142213+01	t
6088a78f-6b47-4ddd-bfb5-de871f67f7e3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:02:40.612993+01	t
012c23f9-2bf1-4dd3-a1cd-fbba522cb953	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:02:48.649018+01	t
47c36d12-89d5-45ba-bfa1-128c930138d6	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:03:38.160358+01	t
9f0363fc-777f-4b00-acd0-2fff60eefa5b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:04:07.852235+01	t
7ec0dbc1-c6f7-43af-b3a8-0da8e7ca236e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:14.872419+01	t
ee4f3e01-2d1e-4040-a929-16cda6a0c0cc	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:15.0433+01	t
9339f7ac-12bf-4c94-8e92-5b8de5da7ce7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:15.42192+01	t
6eb4942e-5588-48c1-bd7e-1cb974ac917f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:15.611454+01	t
37ea902b-b37b-44ed-abd3-67ea725b2122	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:15.803597+01	t
19d1899b-c8c6-4d45-9525-9875fe411ae5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:16.008704+01	t
081e0e39-8c91-4621-98c6-ace0d7c5c2ea	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:16.20847+01	t
23d9b5aa-0653-4b01-b14d-7519c48b82ed	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:23.79664+01	t
506408b1-7a45-44b6-926c-7654ac62d0fb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:23.974955+01	t
e69ae56a-39f1-41b3-89b5-538ca68d53da	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:24.776326+01	t
2187ac31-e2dd-4a98-89b5-d69e9904b13f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:33.847739+01	t
31758095-dbb1-4d0a-9078-b8c286379456	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:34.998355+01	t
558cd0c0-94f9-4f7c-a55f-a6be7e153102	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:35.156593+01	t
bb725b6b-f41e-4f28-ba43-1187627994f3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:35.656979+01	t
243707ba-890b-48d9-a8d8-23fb0c3829c1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:35.873711+01	t
0db5e378-212f-47d7-958c-699269a94595	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:36.137837+01	t
7836efe2-bc5f-4399-af6f-04f043b2d205	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:36.265234+01	t
4e46b71a-e0c5-4ab4-bef1-86188986b941	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:36.502812+01	t
a015e32d-8f8d-4829-acf8-88b9ed76cc2c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:32:44.865369+01	t
50390b20-3deb-47e6-897e-1e6c3d50cda2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:33:04.479763+01	t
ebecf892-1987-41b9-a7a8-e15f38fa7f6f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:33:35.821686+01	t
07e25b35-8d2c-4d57-8ccd-3d6abfcd15d1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:50:36.380419+01	t
2a23298e-c3e2-4197-bdeb-1eeffe5e93a8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:51:05.85834+01	t
719fb392-708f-4605-a328-d984d045cde9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:52:06.221706+01	t
cd09c479-3985-4102-b01b-823a8c364c64	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:56:59.850081+01	t
954ece73-1502-44ef-bcfc-1cd9c2c9ecf9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:03:51.531199+01	t
18d0aa74-e593-4a32-9c32-a14ff5e2420f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:11:38.41906+01	t
3346f899-8c0f-4837-b53c-453337efb31b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:15:57.789535+01	t
a0d349e0-b486-44cb-b14b-1a8f8c5ec76d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:16:23.694688+01	t
08d5a1d2-f5e6-42d9-970d-2dc46a42749b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:41:39.252938+01	t
9725ffe7-7a2e-40d3-aa36-c0852db5c532	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:44:39.734426+01	t
9bc1020b-d539-480b-a0fd-8ae35763fed1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:51:32.09351+01	t
e283c7e8-ef19-4f03-95b7-6c21ca35338f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:52:17.338533+01	t
44e2a5c0-8834-44e9-a89d-2cbc13b784ca	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:52:43.047764+01	t
c3313fb3-464d-45bf-a745-75dbed5cc644	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:53:04.530598+01	t
2bede211-9cb9-4e38-b7d6-e2a84defaa95	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:57:27.438168+01	t
90291d2c-9243-4fbf-b1f6-1870ff12fb8b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:00.958949+01	t
60270a80-f124-4ed3-9a75-b76a08504aef	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:03.336903+01	t
885423b9-34be-4bf5-a425-fb886832f9d5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:04.200958+01	t
8796860d-4593-4406-9aba-1c002990dfdb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:04.383123+01	t
9d0662da-474a-405d-b34c-fd517526dd00	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:04.591472+01	t
62b3a73b-5709-4b46-9c04-13fa64cc9a88	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:05.067501+01	t
88c71c01-0252-483b-8b7d-00d4634ee374	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:05.603439+01	t
38739da5-1a29-4a33-bff1-c62d909798ce	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:05.842783+01	t
e221e987-26e5-43dc-b1ab-fe50689a9801	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.009148+01	t
a111d457-477c-436c-831c-0ce73058fc78	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.252486+01	t
e5d0e876-837c-4a6f-bb4e-6d9cfdc9b92d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.40648+01	t
e3cb8865-7f7f-4743-bf10-87c2276d88f5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.61191+01	t
24c60c96-26c3-4ab2-ad4d-6be688a5062c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.787559+01	t
51ed47f8-96f8-4a29-89eb-348640c8844c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:06.98358+01	t
fde71cfa-2f79-4b56-ae0f-e2daab879ece	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:07.263099+01	t
7aed750a-9138-4348-8283-077b032bdf41	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:08.139505+01	t
428ab376-d047-410d-89c1-4f628fd5e225	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:08.265156+01	t
e1e591fa-f9ea-4fb7-91ac-95f6987203c7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:08.514604+01	t
903f129b-180f-4062-ac39-8202a670322f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:15.196729+01	t
7ff99536-7088-4c77-a7cb-dac837b9cbfc	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:15.937907+01	t
bc0699e9-a848-40dd-b99c-f34e29903095	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:16.393752+01	t
669b1359-fc7f-4565-8794-4031c6d969ba	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:16.544899+01	t
7e36e993-f1ad-4db2-9fd0-0fab86192a5a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:13:16.711889+01	t
4ebbd5a6-457d-4a9e-94f5-94f92ab5770e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:03.579991+01	t
7a5ea57f-1ce7-4ed5-9916-3c5b9c2871d8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:05.092788+01	t
6208d45f-d521-4700-a0ba-91b290f925c0	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:05.911254+01	t
7ad8fbc5-452d-4ad7-88fe-0e142a0fb412	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:06.393678+01	t
d8db6949-a644-40ae-a8b7-4760937fa91e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 06:57:47.21621+01	t
f8f5c56f-ed7a-4250-8b22-fb44076118d3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:10:50.618128+01	t
18a9c078-82ad-41df-a940-2e320743daad	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:33:24.207036+01	t
6cfaa4d4-54c7-4eaf-b0f9-635400154484	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:36:03.985517+01	t
be708e40-1bba-4457-8ad8-b3dd978edfe4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:36:27.856905+01	t
de5cd1db-a816-4cb9-96c6-4231e0d6ce18	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:36:50.407063+01	t
7593d09d-157a-4996-8af3-3cad0635afbe	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:06.543406+01	t
a08b65ee-1539-4167-b408-428a7b879b83	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:07.045067+01	t
3601d102-8a6b-434a-a7bf-65b887b2d7dd	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:07.217722+01	t
067808d8-1144-474f-a2ad-ffba32371fef	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:07.643244+01	t
5f20da8a-6466-476b-bad0-4a9bdb3499bc	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:07.852175+01	t
eaa263ec-0610-4b55-8659-82da79bb6492	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:08.020521+01	t
3727346f-8be4-4594-8274-3799e160dd2a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:08.185222+01	t
057e603d-fe5d-4ca3-bdb4-1a9a8813bae4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:08.454424+01	t
f14884ca-4fcc-448c-bc1a-04add198c038	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:08.609869+01	t
f2e3509f-ac8c-459d-a06a-235835488b8e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:45.387415+01	t
6bb61263-9d00-42e2-bf9b-1c73df555f3f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:46.49177+01	t
d60dc9b2-5e18-4170-b6a1-2048466fd803	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:46.701382+01	t
2677d642-7028-4853-82c3-818673816513	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:15:46.907286+01	t
aa183eb0-f7d6-4ac2-bfe3-1c9024d6f90a	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:19:10.117963+01	t
72353978-fc05-4e3b-b819-9563eed66160	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:30:25.354034+01	t
728e2823-c7a4-44ea-a04b-99ffbf42db7d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:31:26.52845+01	t
15d95fc1-c9b8-437e-a47f-4eab8bfc5fde	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:31:35.158356+01	t
1f7f6929-d34f-4a5f-8515-43e6de4a90ce	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:32:33.522997+01	t
5aed3f9a-941f-4365-8df1-9761cc79eb09	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:05.75958+01	t
fedbafeb-e164-4a61-aa16-bf953abb2d95	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:07.775687+01	t
b3c5c1d2-ac97-4a5e-bfa6-107be48753a1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:08.480139+01	t
a9aff65a-b22e-4a46-a895-0dae9f3cbca4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:08.679589+01	t
5999ffe2-7cbe-4b18-9d6a-547921683803	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:08.871606+01	t
e5c53b0d-a1ba-4222-9176-8917f256c9ea	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:09.070359+01	t
1768316a-363c-4fdc-9efd-843927b80015	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:09.259496+01	t
fcf49c51-4adb-4d24-b9b4-fa2dbada5c3c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:09.573632+01	t
0324a0d1-7675-49e4-bfe5-8e5ed6cf2292	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:09.936099+01	t
044cc2c1-330f-45bc-8c6c-a8319f650912	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:10.174194+01	t
97fc540f-264e-4cb9-8e98-e0ec5ef7f739	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:10.348411+01	t
01c73fa8-4893-4216-bff8-5d1797ad77ff	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:10.830633+01	t
eba47b26-b7ab-478d-a08c-ebb2075957c2	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:11.249973+01	t
cf94b7a6-27cf-411c-9e1d-b177ae9bb9b9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:11.441924+01	t
02f8cf89-03c6-445b-af11-51448e4b80bb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:11.641471+01	t
a60183fa-5324-4c74-85a1-6eacaa38dc52	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:11.811345+01	t
0765f015-07d8-4767-a565-65b8505db113	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:11.972336+01	t
7b7e83e9-d9f5-49e1-847e-3960a03232fa	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:12.063528+01	t
f3704a3a-6eda-4f9b-86ec-31558c494ff9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:12.295671+01	t
2deda7b8-5a05-41d4-9239-20aa4ee0705c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 06:38:12.714009+01	t
e4b5a93c-2c9d-43fa-bfbf-72f682bf0230	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:37:10.653463+01	t
12582cdf-fafd-4340-8e50-55de2ca9a4b9	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:37:36.880544+01	t
a81db40a-8f3e-4fb7-82fb-8ad858ca314f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:38:04.876197+01	t
20329b3c-192d-4668-88a4-1a7645807c52	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:38:22.127701+01	t
b589e7d7-264c-48c5-83d5-3f12a87b2a76	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:39:00.566348+01	t
c6adbdc9-aa80-4387-b537-39b68e5d2a11	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:39:27.947957+01	t
9179b9fb-7f3e-469d-a765-d0b938bd7b6c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:39:42.92062+01	t
cf11d2ac-1d3a-4a17-bd95-575411fac106	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:43:08.468366+01	t
6174c782-c5a7-4f77-9ea5-43168bbba9e0	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:43:32.36049+01	t
b8d65622-134b-4843-85e9-fbb007834db8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:43:59.289631+01	t
3094bb1d-6ddc-46d4-95e7-36120130b3ab	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:44:40.931771+01	t
3282a8f4-0a9c-4641-8908-577e2bece7f7	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:44:58.015698+01	t
c1a1c708-e79f-4552-b663-b36ae8d4a87e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:49:19.077414+01	t
e2c21828-bb01-48ba-b8ac-8dc67ab63ffb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:50:12.796166+01	t
7aa85de1-fe7f-4eb4-900a-b4d2f8e846da	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:50:47.946189+01	t
f9ca8857-ecb9-40f1-82d2-54c6360ec585	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:51:13.215683+01	t
9593c281-a60a-46f6-a4a2-489eb150aaa4	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:51:29.069176+01	t
8939d26d-4bbc-46f3-8834-c0f0ba63d103	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:51:44.566151+01	t
35fb3970-d117-434b-849c-ee23c70833bb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:55:12.819261+01	t
5f3c6261-63d9-4dbb-8018-9e0846553bc3	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 07:55:22.696606+01	t
237f120d-0a80-43ce-9dcb-f8feef1c05ab	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:55:47.538724+01	t
b7fb90e8-6059-4bee-89e9-cf65301d1250	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 07:56:14.833918+01	t
c9b52952-df4c-439f-ba1f-02ee3c0e2bca	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:08:48.541154+01	t
7259587c-5c40-444a-ae9e-85ff87d6ef07	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:09:06.279612+01	t
b6887dbf-7ee7-4cf7-b310-ecc19f397328	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:09:31.274372+01	t
f709a9e6-ee5a-431e-8e79-686bfb856b09	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:13:38.87595+01	t
bb008213-ab7f-4594-9009-8c9e9bb083ac	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:13:59.838567+01	t
c12d3690-19d5-43d8-8a1e-b6a9084ec609	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:14:10.359394+01	t
cb6734a8-3d13-4459-b96a-94ea3d963ebe	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:14:32.605723+01	t
9341848e-473c-4925-85eb-6313f7e0f0bb	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:14:42.883409+01	t
53fc8b48-4c2b-4477-a794-0a44686eb498	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:14:59.930658+01	t
f4d6e82b-2385-4a7e-8d58-14c56150f7da	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:15:08.177086+01	t
8cefd6e9-3a91-4fb9-88df-bc89a0e6c60e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:15:19.968314+01	t
627482f9-9349-4648-b96e-b14652d29d07	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:19:52.245547+01	t
0f048fb1-06a2-44fe-9c45-fb99ab96a69c	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:20:34.417132+01	t
2914d30e-849d-4094-b57e-added161fabe	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:20:46.430537+01	t
723c4ebe-7d3e-4b1f-9730-6ba1a45acc7b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:21:02.004014+01	t
f5696cf5-0261-4a79-b5ef-9c9a1ab62c2b	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:21:13.412448+01	t
22ebd3ab-0299-45e1-a135-1f10da96d66e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:21:24.190814+01	t
0f51a255-cb6c-40ac-9df5-2ae3bfb5fd4e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:21:34.9388+01	t
cbb401c5-de02-42f5-af14-29630a0fcd2f	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:24:55.392689+01	t
e33030ab-c288-4ec7-9c5e-f274842afe41	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	ll	2026-03-02 08:25:48.851118+01	t
8a52256e-1dc9-486a-88db-8d216c2863fd	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:24:27.045696+01	t
6d1f2863-fcca-40e1-a256-722fa0e0a635	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	L	2026-03-02 08:47:39.545847+01	t
2a189b9c-f4ce-4a98-a677-750bd05cc830	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:49:21.875495+01	t
06f19045-4450-464f-9c47-1d2627b3f7b1	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:49:28.702189+01	t
01a1b546-fb7f-4cf1-b688-fb19f19847fa	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:49:40.342295+01	t
de25bfb4-bd90-4f58-badb-3eceb3abf269	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:50:13.051213+01	t
c571504d-65c0-4cb2-a51f-92a7864489a8	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:50:21.979321+01	t
ab2bf5be-e3eb-4b2b-ae44-3df2774c6279	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:50:35.197397+01	t
720988d9-9fb3-4c44-93f2-c4778a50425e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:50:51.073217+01	t
e71230dc-ddd5-42b5-896b-423f84990e31	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	📞 Video call attempt...	2026-03-02 08:51:00.438698+01	t
6c675395-2e9d-4f16-9ee0-4c137e988da5	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:51:30.044772+01	t
6915fcb5-8907-4c9f-bbd7-0431969bdcee	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:51:41.724692+01	t
4fd24710-9457-4b39-9092-0845a72ced5d	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-02 08:51:54.253185+01	t
f6a87f0e-bb40-453b-98c0-11c68a33fb7e	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	hh	2026-03-02 08:56:08.319475+01	t
33ce83d2-ac12-4445-8431-530d9bedac06	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	g	2026-03-04 01:52:53.696641+01	f
13168cc1-cfd5-45f0-8ffa-3ff9daf3f3c1	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	📞 Video call attempt...	2026-03-04 01:53:39.972928+01	f
af436dcd-916f-4cab-8201-5fc7b0b129ee	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	📞 Video call attempt...	2026-03-04 01:58:01.421784+01	f
bc3b8a95-51e8-4515-9cf6-d96cd6baace2	54420f72-9673-404c-a976-61b45320c4af-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	📞 Video call attempt...	2026-03-04 02:01:59.46243+01	f
163d3f7d-6c57-4896-b318-94122aa9de6d	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	l	2026-03-04 04:04:42.73957+01	f
26964181-8e11-4490-9ae7-312d965a5519	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	l	2026-03-04 04:04:47.927915+01	f
3e2d470b-2031-4e06-850e-f10ecb9a7874	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	🙂	2026-03-04 05:19:47.427318+01	f
108e1aae-4147-4096-9d96-82af05cec753	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	oo	2026-03-05 02:59:52.98288+01	t
4251ce6c-1aac-45f2-87f1-c40868754d37	8807bf23-53b6-47f4-a6ba-3af774e3cea0-fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	🎥 Video call attempt	2026-03-05 03:00:11.353428+01	t
\.


--
-- Data for Name: profile_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profile_images (id, profile_id, image_url, created_at) FROM stdin;
\.


--
-- Data for Name: profile_visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profile_visits (id, visitor_id, profile_id, visited_at) FROM stdin;
1529	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	655123bc-07fb-4534-a2ec-9377e9fb36b1	2026-02-08 04:01:38.427111+01
1886	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	b3375eaa-a371-417e-9c18-7b4c36786070	2026-02-16 17:19:15.886813+01
1782	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fd450aea-b2e5-447c-8169-8a07a6db4afd	2026-02-16 17:37:11.523783+01
1888	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1b012a65-c7c3-47ff-844d-2f3140678327	2026-02-16 17:41:51.133053+01
1889	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	09c37999-ad3d-414a-80c3-927e587b4019	2026-02-16 17:43:19.522995+01
1890	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	f5cf5d0d-4073-4cea-b0aa-1cb27d35cf33	2026-02-16 17:46:41.85398+01
1822	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	17a3a2a2-6c31-4614-8ea8-464254847786	2026-02-21 12:33:08.7798+01
1820	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	f35e090d-d8a0-437c-aae1-1735b9eb48cc	2026-02-16 13:13:36.529987+01
1892	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	c1619cfd-8992-469f-b7d9-357983a9af4b	2026-02-16 18:01:19.755494+01
1592	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d004309a-5267-4af3-8216-3c5504ce5425	2026-03-01 06:40:09.79509+01
1826	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	08fdbddf-8510-459c-b576-99151c904c53	2026-02-16 13:43:01.102854+01
1827	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	f27d76a4-28c5-4728-ba00-48fc2451afee	2026-02-16 13:45:13.3046+01
1893	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0180b4f2-fb11-48ae-9e1d-1063082f1df7	2026-02-16 18:02:52.802254+01
1894	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	25136cc9-c962-48d6-9019-97c65c782356	2026-02-16 18:04:54.7558+01
2406	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	935fc335-2d47-4532-87f4-18789f0ff4c2	2026-03-01 09:07:09.04384+01
1895	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54d24948-5e79-4f5a-85c4-0603678116ad	2026-02-16 18:06:42.053891+01
1897	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0d5b43ed-32f3-4ed6-927f-08730e7a6316	2026-02-16 18:12:08.260642+01
1898	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	18befac1-c1a9-4fb7-91ba-f6f1961c3ae3	2026-02-16 18:15:20.566314+01
1899	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	93f5fab8-8ee3-41a5-8c70-5774f103383e	2026-02-16 18:17:27.255582+01
1900	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	0f2ee11b-cd92-403d-a338-01d5a23e6b90	2026-02-16 18:18:15.591945+01
1588	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	4ede5d1d-fea1-44a7-9899-fc89bf583499	2026-03-04 06:17:04.78007+01
1902	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d2371d7c-268f-428a-97db-3951211eebeb	2026-02-16 18:23:17.552856+01
1904	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	43a0c596-d32a-49f7-9177-73daad4ccb67	2026-02-16 18:26:23.822072+01
1905	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	e994d87d-2ef0-41a5-b14c-ed37dc113809	2026-02-16 18:29:02.010958+01
1906	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	bfbf77c7-1f07-499d-bfdd-ef235db91fc6	2026-02-16 18:30:29.625315+01
1907	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	bb3ce1ea-5bf9-4c83-ac06-da0e68c6c4d4	2026-02-16 18:30:58.896977+01
1908	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	ffa83ce2-cdf9-4bf9-80b2-e1148c0e4ba2	2026-02-16 18:42:15.642155+01
1909	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1465a6aa-62cc-41d7-8758-8133af0b6f36	2026-02-16 18:43:15.011293+01
1825	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	15d1840c-2532-4333-8c23-f98034b3d1c1	2026-02-22 19:41:48.788869+01
1911	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	84e8f52d-3bbb-49e3-90bc-cfe7563dcc2b	2026-02-16 18:46:42.565684+01
1913	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	22c98c03-fc65-4275-9ff5-f190eeb36879	2026-02-16 18:53:11.00579+01
1914	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	3696f785-b546-49ac-833b-80307e491325	2026-02-16 19:02:40.599789+01
1915	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	e04e8dfa-a7f2-4d4a-9fa2-d4b8c52d4334	2026-02-16 19:46:51.025725+01
1917	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8ba1ad2f-47b6-4b0f-9490-8bbb2ecc5a79	2026-02-16 20:07:14.889369+01
1919	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	10d9bb78-1fe4-4937-99cc-320770ef6f25	2026-02-16 20:08:14.517011+01
1920	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	97cb730b-5331-492a-aa57-fa8244e5a049	2026-02-16 20:09:01.686133+01
2391	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	e8b2871b-184a-4228-a32d-1fb0eff39a8b	2026-02-22 21:59:04.221632+01
1921	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	7172cbb9-4cc9-488e-8d19-43c04e168031	2026-02-16 20:10:19.382515+01
1922	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	ea165cdc-2446-423b-8556-8ee2eccf52d7	2026-02-16 20:40:08.130467+01
1923	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	23f43d13-4ba0-41aa-b608-0594775e99ee	2026-02-16 20:40:51.969224+01
1924	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	f23685c7-29af-4fa6-a3dd-e282aaac9640	2026-02-16 20:41:39.932705+01
1593	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	5157ac77-1580-4cdb-94ba-0778279c53b9	2026-02-23 16:36:30.639764+01
1932	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	2026-03-04 17:15:36.204621+01
1861	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	16270494-beb5-4dbe-a23c-8dcca21fec50	2026-02-16 15:54:56.922649+01
1862	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	6bcfed40-1652-400e-a4fb-116222436811	2026-02-16 15:56:03.157481+01
1863	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	30393e69-d59d-4a66-bea3-b9a3b857a389	2026-02-16 15:59:02.008687+01
1865	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d1a8adda-dc9f-41b5-9256-7283e12ac6ea	2026-02-16 16:00:44.504146+01
1866	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	9aa187ae-0ef3-47e0-8600-3cb5919ffe9e	2026-02-16 16:02:41.553888+01
1867	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	ab8bafac-187d-4918-82af-d55056176543	2026-02-16 16:04:25.382622+01
1868	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	4ea72160-dffc-44c3-aa67-38a3148d2deb	2026-02-16 16:06:30.031337+01
1891	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	80634134-6662-452b-be5f-3541ad7cc9ec	2026-02-23 16:42:50.342383+01
1869	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	46a4abc9-1562-4f46-becf-698bf579e998	2026-02-16 16:26:56.395196+01
1872	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	4ebe117b-c139-4d37-a7f9-e86989172ef3	2026-02-16 16:33:34.887204+01
1873	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	112e725b-6f5b-4f96-a049-a222be80b855	2026-02-16 16:36:14.458962+01
1874	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	9e67a469-a4e3-44b2-9060-c7b5809cab5c	2026-02-16 16:39:39.692469+01
1875	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	fd92da0f-75ca-4c92-b13a-097335a343c6	2026-02-16 16:43:21.274255+01
1876	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	5e3176b1-53c2-4846-9768-9217afceb9fb	2026-02-16 16:47:10.792413+01
1586	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	1230acac-7210-49d2-8323-27b7c0c31bbf	2026-02-16 16:50:28.129923+01
1878	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	e8b2871b-184a-4228-a32d-1fb0eff39a8b	2026-02-16 16:53:11.852891+01
1879	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	a3d26499-be2f-45af-9953-158b8b17ad9a	2026-02-16 17:00:01.679769+01
2439	8807bf23-53b6-47f4-a6ba-3af774e3cea0	54420f72-9673-404c-a976-61b45320c4af	2026-03-05 03:27:16.578549+01
2437	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	2026-03-05 19:59:42.758656+01
1885	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	66eb3e5b-dcb6-4ce6-b64e-b2b7fcbd9270	2026-02-23 16:45:49.553373+01
2440	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	54420f72-9673-404c-a976-61b45320c4af	2026-03-01 08:21:55.996733+01
1525	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	565d9fbd-4638-48c9-9845-9e18ad10db67	2026-03-01 08:22:37.774626+01
2615	8807bf23-53b6-47f4-a6ba-3af774e3cea0	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	2026-03-02 07:39:24.143248+01
2436	8807bf23-53b6-47f4-a6ba-3af774e3cea0	68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	2026-03-03 05:57:03.408472+01
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, email, password, display_name, is_admin, created_at, bio, is_banned, banned_at, banned_reason, updated_at, gender, sexuality, age, town, country, photo_url, is_online, last_seen, is_setup, looking_for, education, religion, smoker, drinker, city, phone_number, gallery_urls, consent_ip, consent_date, reset_token, reset_token_expires, credits, referred_by, affiliate_balance, is_ghost_mode, total_private_messages_sent, total_lobby_messages_sent, height, weight, hair_color, eye_color, music_preference, body_type, zodiac_sign, date_of_birth) FROM stdin;
54420f72-9673-404c-a976-61b45320c4af	admifffffn@teddst.com	$2b$12$A8Mp1yBVCN/h/HqZ7/DzEOw0BhTRP1zQclAiHB2prLZ4tpydJn7wG	admifffffn	f	2026-03-01 08:10:58.373739+01	\N	f	\N	\N	2026-03-01 08:11:05.244795+01	\N	\N	\N	\N	\N	\N	t	2026-03-01 08:11:05.244795+01	f	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	admin@test.com	$2a$10$vI8p2/67xL3fCExU2yH70uE6/9.uX098/9e123456789012345678	Admin User	t	2026-01-22 04:02:56.512548+01	Mooo	f	\N	\N	2026-03-06 09:33:37.023236+01	male	other	44	\N	Other	https://res.cloudinary.com/do54j5dgq/image/upload/v1771876561/dating_app_photos/bxjwbpguncbuubuqzung.webp	t	2026-03-06 09:33:37.023236+01	t	New Friends	High School	Christian	No	Socially	\N	+381638966250	{}	::1	2026-02-23 20:56:05.613	\N	\N	100	\N	0.00	f	0	0	193	98	Brown	Not specified	Other	Athletic	Pisces	1981-02-26
68747a01-29b3-4f9f-8bb3-eb233dbd9a2d	mikiniki12ffffff3347hhy77@gmail.com	$2b$12$nT4ER4cmmyO0nt4fF6hmXep122MTmEFg.2Hu.MnjFio16.gTjQDOm	mikiniki12ffffff3347hhy77	f	2026-02-18 16:40:14.188746+01	\N	f	\N	\N	2026-02-22 21:59:06.591894+01	\N	\N	\N	\N	\N	\N	t	2026-02-22 21:59:06.591894+01	f	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
8807bf23-53b6-47f4-a6ba-3af774e3cea0	ksoskbgsoskkj@hotmail.com	$2b$12$82Pe6sdbN5HBCNF8Xx9jPO4H01wlqbbnB/wcDEGc.pzoADygE9uny	ksoskbgsoskkj	f	2026-03-01 08:13:13.205208+01	\N	f	\N	\N	2026-03-05 21:16:40.644977+01	\N	\N	\N	\N	\N	\N	t	2026-03-05 21:16:40.644977+01	f	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	3	0	\N	\N	\N	\N	\N	\N	\N	\N
935fc335-2d47-4532-87f4-18789f0ff4c2	guotyrerrr56dd6677@gmail.com	$2b$12$QprxVK4hU/e9K3p8hSrSUOG9W4ECL66GG0njWble.A6joZRFBQJJ.	guotyrerrr56dd6677	f	2026-02-18 15:31:24.465447+01	\N	f	\N	\N	2026-02-23 20:11:34.772836+01	\N	\N	\N	\N	\N	\N	t	2026-02-19 09:32:40.203204+01	f	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
4ede5d1d-fea1-44a7-9899-fc89bf583499	bot_f_63026@dateroot.com	hashed_pass	Victoria Hill	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-23 20:03:33.193312+01	female	other	35	London	United Kingdom	https://i.pravatar.cc/400?u=bot_f_63026@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Something Casual	University	Christian	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
5157ac77-1580-4cdb-94ba-0778279c53b9	bot_f_53684@dateroot.com	hashed_pass	Megan	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 13:23:27.454144+01	female	lesbian	30	Melbourne	Australia	https://i.pravatar.cc/400?u=bot_f_53684@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Masters	Other	Yes	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
565d9fbd-4638-48c9-9845-9e18ad10db67	bot_f_33888@dateroot.com	hashed_pass	Dan	f	2026-02-08 02:20:05.360391+01	Coffee addict ?	f	\N	\N	2026-02-23 22:23:18.872572+01	female	gay	57	San Diego	\N	\N	t	2026-02-08 02:20:05.360391+01	t	New Friends	High School	Christian	Occasionally	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
d004309a-5267-4af3-8216-3c5504ce5425	bot_f_89548@dateroot.com	hashed_pass	Faith	f	2026-02-08 02:20:05.360391+01	Tacos? ??	f	\N	\N	2026-02-16 18:49:18.368222+01	female	heterosexual	29	Los Angeles	\N	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264118/dating_app_photos/gosjiuaylsupdd4xa9oz.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
23f43d13-4ba0-41aa-b608-0594775e99ee	bot_f_52003@dateroot.com	hashed_pass	Heat	f	2026-02-08 02:20:05.360391+01	Coffee addict ?	f	\N	\N	2026-02-16 20:40:51.618785+01	female	heterosexual	26	Dallas	\N	https://i.pravatar.cc/400?u=bot_f_52003@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
f35e090d-d8a0-437c-aae1-1735b9eb48cc	bot_f_44921@dateroot.com	hashed_pass	Kayla	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-16 13:13:36.017835+01	female	heterosexual	32	Phoenix	USA	https://res.cloudinary.com/do54j5dgq/image/upload/v1771243950/dating_app_photos/vixg7zganwh4a169ymtq.webp	t	2026-02-08 02:20:05.360391+01	t	New Friends	University	Private	Yes	Socially	\N	\N	{https://res.cloudinary.com/do54j5dgq/image/upload/v1771243950/dating_app_photos/mmbrfgimfc7hdpth3ou6.webp}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
17a3a2a2-6c31-4614-8ea8-464254847786	bot_f_7915@dateroot.com	hashed_pass	Tim 2026	f	2026-02-08 02:20:05.360391+01	Netflix? ??	f	\N	\N	2026-02-16 13:18:56.122615+01	male	bisexual	41	Seattle	USA	https://i.pravatar.cc/400?u=bot_f_7915@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Masters	Atheist	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
1230acac-7210-49d2-8323-27b7c0c31bbf	bot_f_21748@dateroot.com	hashed_pass	Ashley	f	2026-02-08 02:20:05.360391+01	Soulmate search,,,,,,,,,,,,,,,,,,,,,,,,	f	\N	\N	2026-02-16 16:50:27.833369+01	female	heterosexual	29	Detroit	USA	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256949/dating_app_photos/qps8kgik6qxv92700qnn.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	179	75	Black	Brown	\N	\N	\N	\N
80634134-6662-452b-be5f-3541ad7cc9ec	bot_f_40500@dateroot.com	hashed_pass	Ivan Petrushev	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 17:53:55.492571+01	female	heterosexual	49	Odesa	Ukraine	https://i.pravatar.cc/400?u=bot_f_40500@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
fd450aea-b2e5-447c-8169-8a07a6db4afd	bot_f_55057@dateroot.com	hashed_pass	rob	f	2026-02-08 02:20:05.360391+01	I’m a coffee lover with a caffeine addiction.	f	\N	\N	2026-02-23 20:03:35.975663+01	female	heterosexual	33	Lyon	France	https://i.pravatar.cc/400?u=bot_f_55057@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Marriage	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
e8b2871b-184a-4228-a32d-1fb0eff39a8b	bot_f_3416@dateroot.com	hashed_pass	East Johny 26	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:53:11.527823+01	female	heterosexual	20	\N	United Kingdom	https://res.cloudinary.com/do54j5dgq/image/upload/v1771257132/dating_app_photos/kxsqdxwosjqbli5egm9b.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
ea165cdc-2446-423b-8556-8ee2eccf52d7	bot_f_80762@dateroot.com	hashed_pass	Jennifer	f	2026-02-08 02:20:05.360391+01	Love traveling! ??	f	\N	\N	2026-02-16 20:40:07.682383+01	female	heterosexual	24	Houston	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
f23685c7-29af-4fa6-a3dd-e282aaac9640	bot_f_48025@dateroot.com	hashed_pass	S.E	f	2026-02-08 02:20:05.360391+01	Adventure? ???	f	\N	\N	2026-02-16 20:41:39.639187+01	female	heterosexual	30	Houston	\N	https://i.pravatar.cc/400?u=bot_f_48025@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
08fdbddf-8510-459c-b576-99151c904c53	bot_f_7528@dateroot.com	hashed_pass	Charlotte 2026	f	2026-02-08 02:20:05.360391+01	I’m small but mighty! I work in finance and I’m very disciplined, but I know how to let loose on the weekends. Looking for someone who is confident enough to handle a woman with her own opinions.	f	\N	\N	2026-02-16 13:43:00.710464+01	female	heterosexual	25	New York	USA	https://res.cloudinary.com/do54j5dgq/image/upload/v1771245603/dating_app_photos/u3sxtmgcrjaxinqtwvm5.webp	t	2026-02-08 02:20:05.360391+01	t	Marriage	University	Atheist	Yes	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
16270494-beb5-4dbe-a23c-8dcca21fec50	bot_f_47072@dateroot.com	hashed_pass	Brittany	f	2026-02-08 02:20:05.360391+01	Soulmate search ??	f	\N	\N	2026-02-16 15:54:56.593593+01	female	heterosexual	54	Phoenix	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Not Sure Yet	Not specified	Jewish	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	165	68	Black	Brown	\N	\N	\N	\N
355d7c85-4257-483b-98a5-0823c643603f	bot_f_94188@dateroot.com	hashed_pass	Nicole	f	2026-02-08 02:20:05.360391+01	Say hi!	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	27	Dallas	\N	https://i.pravatar.cc/400?u=bot_f_94188@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
c93547d8-e8b6-4c6f-bdfd-d52da8461ec2	bot_f_26479@dateroot.com	hashed_pass	Olivia	f	2026-02-08 02:20:05.360391+01	Adventure? ???	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	22	Dallas	\N	https://i.pravatar.cc/400?u=bot_f_26479@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
15d1840c-2532-4333-8c23-f98034b3d1c1	bot_f_70978@dateroot.com	hashed_pass	Samantha	f	2026-02-08 02:20:05.360391+01	I'm a nurse, so I've seen it all.	f	\N	\N	2026-02-16 13:38:55.562211+01	female	bisexual	30	London	United Kingdom	https://res.cloudinary.com/do54j5dgq/image/upload/v1771244687/dating_app_photos/mmgsy5ykwnkcqwakaux5.webp	t	2026-02-08 02:20:05.360391+01	t	Not Sure Yet	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
f27d76a4-28c5-4728-ba00-48fc2451afee	bot_f_50807@dateroot.com	hashed_pass	Noah Smith	f	2026-02-08 02:20:05.360391+01	Tech startup founder. I work hard, play hard, and sleep even harder. I value intelligence and a man who can challenge me. If you’re intimidated by strong women, keep scrolling.	f	\N	\N	2026-02-16 13:45:12.731742+01	female	heterosexual	23	Los Angeles	USA	https://i.pravatar.cc/400?u=bot_f_50807@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	High School	Muslim	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
7729fa25-906a-4488-bece-86a65d8e53fd	bot_f_77684@dateroot.com	hashed_pass	Sarah	f	2026-02-08 02:20:05.360391+01	Gym girl ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	23	San Jose	\N	https://i.pravatar.cc/400?u=bot_f_77684@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
20221304-1cf4-446b-ba57-5beba08bdfb4	bot_f_43088@dateroot.com	hashed_pass	Isabella	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	29	San Antonio	\N	https://i.pravatar.cc/400?u=bot_f_43088@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
945d3d8c-1873-4d0f-aa82-881c9d64f217	bot_f_41565@dateroot.com	hashed_pass	Samantha	f	2026-02-08 02:20:05.360391+01	Netflix? ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	26	Dallas	\N	https://i.pravatar.cc/400?u=bot_f_41565@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
09c37999-ad3d-414a-80c3-927e587b4019	bot_f_70966@dateroot.com	hashed_pass	josh 1	f	2026-02-08 02:20:05.360391+01	Adventure?	f	\N	\N	2026-02-16 17:43:19.11404+01	female	heterosexual	21	Phoenix	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	189	79	Not specified	Not specified	\N	\N	\N	\N
0180b4f2-fb11-48ae-9e1d-1063082f1df7	bot_f_81104@dateroot.com	hashed_pass	Elizabeth 111	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:02:52.404167+01	female	heterosexual	19	Budapest	Hungary	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
c1ec4cff-c42c-40e6-8572-f237232bc9d3	bot_f_85464@dateroot.com	hashed_pass	Emma	f	2026-02-08 02:20:05.360391+01	Adventure? ???	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	24	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_f_85464@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
4dd25cbd-0db9-49a4-9717-8ee5b384a372	bot_f_2777@dateroot.com	hashed_pass	Nicole	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	22	San Jose	\N	https://i.pravatar.cc/400?u=bot_f_2777@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
1d6fa772-3202-43dc-a56c-6dd159421101	bot_f_50629@dateroot.com	hashed_pass	Emma	f	2026-02-08 02:20:05.360391+01	Adventure? ???	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	30	San Diego	\N	https://i.pravatar.cc/400?u=bot_f_50629@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
c1619cfd-8992-469f-b7d9-357983a9af4b	bot_f_97795@dateroot.com	hashed_pass	Andreas Georgiou	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:01:19.363833+01	female	heterosexual	52	Athens	Greece	https://res.cloudinary.com/do54j5dgq/image/upload/v1771261122/dating_app_photos/lk3v0sj0thhrrpyka3z8.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Christian	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	174	78	Black	Brown	\N	\N	\N	\N
0f2ee11b-cd92-403d-a338-01d5a23e6b90	bot_f_32959@dateroot.com	hashed_pass	Samantha	f	2026-02-08 02:20:05.360391+01	Coffee addict ?	f	\N	\N	2026-02-16 18:18:15.226131+01	female	heterosexual	30	Philadelphia	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
10d9bb78-1fe4-4937-99cc-320770ef6f25	bot_f_90957@dateroot.com	hashed_pass	Tim D.	f	2026-02-08 02:20:05.360391+01	Netflix? ??	f	\N	\N	2026-02-16 20:08:14.189771+01	female	heterosexual	23	Chicago	\N	https://i.pravatar.cc/400?u=bot_f_90957@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
9aa187ae-0ef3-47e0-8600-3cb5919ffe9e	bot_f_78885@dateroot.com	hashed_pass	Kayla	f	2026-02-08 02:20:05.360391+01	Love traveling	f	\N	\N	2026-02-16 16:02:41.196257+01	female	heterosexual	36	Vienna	Austria	\N	t	2026-02-08 02:20:05.360391+01	t	New Friends	University	Christian	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	179	70	Black	Brown	\N	\N	\N	\N
2b6d9b67-85b4-446a-a161-5c7087923484	bot_f_63499@dateroot.com	hashed_pass	Amanda	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	22	San Jose	\N	https://i.pravatar.cc/400?u=bot_f_63499@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
a3d26499-be2f-45af-9953-158b8b17ad9a	bot_f_74151@dateroot.com	hashed_pass	Brittany Fischer	f	2026-02-08 02:20:05.360391+01	Looking for fun!	f	\N	\N	2026-02-16 17:00:01.317093+01	female	heterosexual	26	London	United Kingdom	https://res.cloudinary.com/do54j5dgq/image/upload/v1771257280/dating_app_photos/e7himgd4vmvua1mekr45.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	183	70	Black	Brown	\N	\N	\N	\N
66eb3e5b-dcb6-4ce6-b64e-b2b7fcbd9270	bot_f_32595@dateroot.com	hashed_pass	Ron (DE)	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 17:11:31.654973+01	female	heterosexual	48	Munich	Germany	https://i.pravatar.cc/400?u=bot_f_32595@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Something Casual	High School	Atheist	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	190	78	Bald	Brown	\N	\N	\N	\N
fd92da0f-75ca-4c92-b13a-097335a343c6	bot_f_57533@dateroot.com	hashed_pass	Sophia Dubois	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:43:20.961875+01	female	heterosexual	22	Paris	France	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256442/dating_app_photos/i3efnxktwwro9lvczg4r.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Brown	Green	\N	\N	\N	\N
46fe8f50-0e24-4f78-af23-6b223e74ce3a	bot_f_29489@dateroot.com	hashed_pass	Mia	f	2026-02-08 02:20:05.360391+01	Coffee addict ?	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	19	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_f_29489@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
b3375eaa-a371-417e-9c18-7b4c36786070	bot_f_68555@dateroot.com	hashed_pass	Sophia Schneider	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 17:19:15.417877+01	female	bisexual	25	Vienna	Austria	https://res.cloudinary.com/do54j5dgq/image/upload/v1771258340/dating_app_photos/gnp77kc21faklc0cu5qe.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Jewish	Occasionally	Socially	\N	\N	{https://res.cloudinary.com/do54j5dgq/image/upload/v1771258352/dating_app_photos/opsexgxic4gfjurpxig7.webp}	\N	\N	\N	\N	100	\N	0.00	f	0	0	170	58	Brown	Brown	\N	\N	\N	\N
54d24948-5e79-4f5a-85c4-0603678116ad	bot_f_68123@dateroot.com	hashed_pass	Prophet	f	2026-02-08 02:20:05.360391+01	Adventure? ???	f	\N	\N	2026-02-16 18:06:41.571952+01	female	heterosexual	67	Chicago	\N	https://i.pravatar.cc/400?u=bot_f_68123@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
22c98c03-fc65-4275-9ff5-f190eeb36879	bot_f_44824@dateroot.com	hashed_pass	Megan	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:53:10.660242+01	female	heterosexual	30	Amsterdam	Netherlands	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264332/dating_app_photos/d7tachedktjynwuxpid4.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	No	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Brown	Brown	\N	\N	\N	\N
60119fd3-0277-4ada-8964-e6dcbdfadb33	bot_f_64443@dateroot.com	hashed_pass	Kayla	f	2026-02-08 02:20:05.360391+01	Tacos? ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	28	San Jose	\N	https://i.pravatar.cc/400?u=bot_f_64443@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
34d96907-a5f0-4dac-be24-7267829261e8	bot_f_73465@dateroot.com	hashed_pass	Megan	f	2026-02-08 02:20:05.360391+01	Looking for fun! ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	28	Philadelphia	\N	https://i.pravatar.cc/400?u=bot_f_73465@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
3e2e92a7-ca7c-4551-abbe-efe21fe4e1d5	bot_f_84373@dateroot.com	hashed_pass	Ashley	f	2026-02-08 02:20:05.360391+01	Music lover ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	26	San Antonio	\N	https://i.pravatar.cc/400?u=bot_f_84373@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
b05bc5ef-3e6c-4a93-b787-f8eff92f1786	bot_f_36570@dateroot.com	hashed_pass	Emma	f	2026-02-08 02:20:05.360391+01	Soulmate search ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	24	Philadelphia	\N	https://i.pravatar.cc/400?u=bot_f_36570@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
6bcfed40-1652-400e-a4fb-116222436811	bot_f_41666@dateroot.com	hashed_pass	Charlotte	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 15:56:02.794527+01	female	heterosexual	20	Buenos Aires	Argentina	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	Yes	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Red	Blue	\N	\N	\N	\N
e994d87d-2ef0-41a5-b14c-ed37dc113809	bot_m_7509@dateroot.com	hashed_pass	Nicky	f	2026-02-08 02:20:05.360391+01	Looking for something real.	f	\N	\N	2026-02-16 18:29:01.642306+01	male	heterosexual	24	New York	\N	https://i.pravatar.cc/400?u=bot_m_7509@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
97cb730b-5331-492a-aa57-fa8244e5a049	bot_f_87377@dateroot.com	hashed_pass	sarah	f	2026-02-08 02:20:05.360391+01	Tacos? ??	f	\N	\N	2026-02-16 20:09:01.352396+01	female	heterosexual	23	Philadelphia	\N	https://i.pravatar.cc/400?u=bot_f_87377@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
4498d554-17b5-4722-813a-a70e6a04a22e	bot_f_8441@dateroot.com	hashed_pass	Elizabeth	f	2026-02-08 02:20:05.360391+01	Tacos? ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	24	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_f_8441@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
8fa0249e-8a3e-413b-a639-aac56e918dd1	bot_f_68173@dateroot.com	hashed_pass	Hannah	f	2026-02-08 02:20:05.360391+01	Coffee addict ?	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	19	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_f_68173@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
d0275b99-54b5-4be8-b520-1348c61322e9	bot_f_59566@dateroot.com	hashed_pass	Charlotte	f	2026-02-08 02:20:05.360391+01	Tacos? ??	f	\N	\N	2026-02-08 02:20:05.360391+01	female	\N	27	Chicago	\N	https://i.pravatar.cc/400?u=bot_f_59566@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
655123bc-07fb-4534-a2ec-9377e9fb36b1	bot_m_74046@dateroot.com	hashed_pass	William	f	2026-02-08 02:20:05.360391+01	Lets grab a drink ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	23	San Diego	\N	https://i.pravatar.cc/400?u=bot_m_74046@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
ab8bafac-187d-4918-82af-d55056176543	bot_m_27395@dateroot.com	hashed_pass	Kevin	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:04:24.897809+01	male	heterosexual	63	Dallas	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Marriage	Masters	Jewish	Yes	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	185	89	White	Brown	\N	\N	\N	\N
84e8f52d-3bbb-49e3-90bc-cfe7563dcc2b	bot_m_57952@dateroot.com	hashed_pass	Ilona HU	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:46:42.105072+01	male	heterosexual	32	Budapest	Hungary	https://res.cloudinary.com/do54j5dgq/image/upload/v1771263917/dating_app_photos/r5nxcm14j0odlfh7h1xv.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	High School	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	176	60	Not specified	Not specified	\N	\N	\N	\N
5e3176b1-53c2-4846-9768-9217afceb9fb	bot_m_72918@dateroot.com	hashed_pass	Mike De Boer	f	2026-02-08 02:20:05.360391+01	Lets grab a drink ??	f	\N	\N	2026-02-16 16:47:10.391488+01	male	heterosexual	26	The Hague	Netherlands	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256713/dating_app_photos/e5jbgvetr9fbbwkpikad.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	Yes	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	168	65	Brown	Not specified	\N	\N	\N	\N
0d5b43ed-32f3-4ed6-927f-08730e7a6316	bot_m_32774@dateroot.com	hashed_pass	Nicholas	f	2026-02-08 02:20:05.360391+01	Lets grab a drink ??	f	\N	\N	2026-02-16 18:12:07.801667+01	male	heterosexual	39	San Diego	\N	https://i.pravatar.cc/400?u=bot_m_32774@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
93f5fab8-8ee3-41a5-8c70-5774f103383e	bot_m_35181@dateroot.com	hashed_pass	Liss @	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:17:26.92048+01	female	lesbian	34	Vancouver	Canada	https://i.pravatar.cc/400?u=bot_m_35181@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	179	65	Not specified	Not specified	\N	\N	\N	\N
d2371d7c-268f-428a-97db-3951211eebeb	bot_m_93754@dateroot.com	hashed_pass	Nia	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:23:17.20629+01	male	heterosexual	43	Lagos	Nigeria	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262450/dating_app_photos/ydxgr6kpvb0dp5si7moy.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
8ba1ad2f-47b6-4b0f-9490-8bbb2ecc5a79	bot_m_22652@dateroot.com	hashed_pass	Thomas	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-16 20:07:14.489884+01	female	bisexual	50	Bergen	Norway	https://res.cloudinary.com/do54j5dgq/image/upload/v1771268621/dating_app_photos/z5ecwdpsepuk1n3pppkw.webp	t	2026-02-08 02:20:05.360391+01	t	Not Sure Yet	Masters	Private	Yes	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	180	75	Brown	Green	\N	\N	\N	\N
74d802b1-9843-4323-8862-fd36b9d15235	bot_m_19508@dateroot.com	hashed_pass	Kevin	f	2026-02-08 02:20:05.360391+01	Entrepreneur ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	23	Philadelphia	\N	https://i.pravatar.cc/400?u=bot_m_19508@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
5c35135e-f89a-4b72-9c3c-569fa8bf6e77	bot_m_71841@dateroot.com	hashed_pass	Justin	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	24	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_71841@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
80bf5809-fda3-4615-ade0-f2c493801f36	bot_m_30101@dateroot.com	hashed_pass	Timothy	f	2026-02-08 02:20:05.360391+01	Traveler ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	23	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_30101@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
a57f2ceb-f0a5-4e9b-a111-8196dd49bf81	bot_m_90381@dateroot.com	hashed_pass	Ryan	f	2026-02-08 02:20:05.360391+01	Looking for something real.	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	33	San Jose	\N	https://i.pravatar.cc/400?u=bot_m_90381@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
a5760132-7b52-4ee0-93f9-7a0a5ddae868	bot_m_19648@dateroot.com	hashed_pass	Eric	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	21	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_19648@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
4ea72160-dffc-44c3-aa67-38a3148d2deb	bot_m_5542@dateroot.com	hashed_pass	Kumar	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:06:29.731105+01	male	heterosexual	29	Mumbai	India	https://res.cloudinary.com/do54j5dgq/image/upload/v1771254310/dating_app_photos/ktdwso2fpdbymaujb5lb.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Private	Yes	No	\N	\N	{https://res.cloudinary.com/do54j5dgq/image/upload/v1771254315/dating_app_photos/ez8hxqe2fyawhkuio6so.webp}	\N	\N	\N	\N	100	\N	0.00	f	0	0	173	75	Black	Brown	\N	\N	\N	\N
4ebe117b-c139-4d37-a7f9-e86989172ef3	bot_m_8577@dateroot.com	hashed_pass	Steven	f	2026-02-08 02:20:05.360391+01	I love cooking for people. I’m a restaurant manager who knows everyone in the industry. I’m looking for a partner who appreciates a good meal and great conversation.	f	\N	\N	2026-02-16 16:33:34.469934+01	male	heterosexual	21	Espoo	Finland	https://res.cloudinary.com/do54j5dgq/image/upload/v1771255691/dating_app_photos/vy4x1mmvucd1rt5jghmy.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Christian	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	180	90	White	Brown	\N	\N	\N	\N
112e725b-6f5b-4f96-a049-a222be80b855	bot_m_94921@dateroot.com	hashed_pass	Helly B	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:36:14.081035+01	female	lesbian	32	Johannesburg	South Africa	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256101/dating_app_photos/aeuzzghswmytx64oymtr.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	High School	Muslim	Yes	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	184	70	Black	Brown	\N	\N	\N	\N
e04e8dfa-a7f2-4d4a-9fa2-d4b8c52d4334	bot_m_14521@dateroot.com	hashed_pass	Justin 21	f	2026-02-08 02:20:05.360391+01	Chill vibes only.	f	\N	\N	2026-02-16 19:46:50.715192+01	male	heterosexual	21	San Antonio	\N	https://i.pravatar.cc/400?u=bot_m_14521@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
18befac1-c1a9-4fb7-91ba-f6f1961c3ae3	bot_m_34746@dateroot.com	hashed_pass	Nicholas	f	2026-02-08 02:20:05.360391+01	Chill vibes only :)	f	\N	\N	2026-02-16 18:15:20.169063+01	male	heterosexual	29	Cartago	Costa Rica	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262046/dating_app_photos/itmapcjysflviqzroig2.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{https://res.cloudinary.com/do54j5dgq/image/upload/v1771262055/dating_app_photos/bx71gv026d2ph6dradcf.webp}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
43a0c596-d32a-49f7-9177-73daad4ccb67	bot_m_32979@dateroot.com	hashed_pass	Maria	f	2026-02-08 02:20:05.360391+01	Passion is my fashion!!!	f	\N	\N	2026-02-16 18:26:23.390243+01	male	heterosexual	45	San Antonio	\N	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262728/dating_app_photos/xaeeb4r3bqljlvxf6kka.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Christian	Yes	No	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
87873351-fd25-47c1-b1c8-371544f2223b	bot_m_33133@dateroot.com	hashed_pass	Kevin	f	2026-02-08 02:20:05.360391+01	Dog dad ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	30	San Jose	\N	https://i.pravatar.cc/400?u=bot_m_33133@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
9e67a469-a4e3-44b2-9060-c7b5809cab5c	bot_m_54833@dateroot.com	hashed_pass	Hanna Müller	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 16:39:39.284053+01	male	heterosexual	35	Hamburg	Germany	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256253/dating_app_photos/wqech1cvvhlc8wkcg5h5.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	High School	Private	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	175	72	Brown	Brown	\N	\N	\N	\N
3696f785-b546-49ac-833b-80307e491325	bot_m_26615@dateroot.com	hashed_pass	Veronica Richardson	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 19:02:40.245271+01	male	heterosexual	33	Phoenix	\N	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264900/dating_app_photos/ftc1uewowm1cjrpgcuxk.webp	t	2026-02-08 02:20:05.360391+01	t	Something Casual	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
7129342a-35d1-43c0-9455-22e5bd03b652	bot_m_25462@dateroot.com	hashed_pass	Eric	f	2026-02-08 02:20:05.360391+01	Traveler ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	33	Phoenix	\N	https://i.pravatar.cc/400?u=bot_m_25462@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
8d55cb5f-f36d-4658-a565-2ec14520d546	bot_m_66111@dateroot.com	hashed_pass	Joshua	f	2026-02-08 02:20:05.360391+01	Chill vibes only.	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	21	Houston	\N	https://i.pravatar.cc/400?u=bot_m_66111@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
1465a6aa-62cc-41d7-8758-8133af0b6f36	bot_m_68902@dateroot.com	hashed_pass	Justin	f	2026-02-08 02:20:05.360391+01	Looking for something real.	f	\N	\N	2026-02-16 18:43:14.672507+01	female	lesbian	32	Houston	\N	https://i.pravatar.cc/400?u=bot_m_68902@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
f087d366-189d-4d6a-bccb-bf6458fa58e3	bot_m_51230@dateroot.com	hashed_pass	Brian	f	2026-02-08 02:20:05.360391+01	Chill vibes only.	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	23	San Jose	\N	https://i.pravatar.cc/400?u=bot_m_51230@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
46a4abc9-1562-4f46-becf-698bf579e998	bot_m_75018@dateroot.com	hashed_pass	Noah Bouton	f	2026-02-08 02:20:05.360391+01	I’m a freelance photographer specializing in street style. I’m a bit of an introvert until the music starts playing. Looking for a partner-in-crime who isn't afraid to try that weird-looking restaurant on the corner.	f	\N	\N	2026-02-16 16:26:32.135629+01	male	heterosexual	27	Brussels	Belgium	https://res.cloudinary.com/do54j5dgq/image/upload/v1771254485/dating_app_photos/xtklqjeadnbkdwgtla2l.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	182	85	Not specified	Not specified	\N	\N	\N	\N
d241be07-161c-424d-85d6-06516a330035	bot_m_16485@dateroot.com	hashed_pass	Jason	f	2026-02-08 02:20:05.360391+01	Chill vibes only.	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	21	San Diego	\N	https://i.pravatar.cc/400?u=bot_m_16485@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
25136cc9-c962-48d6-9019-97c65c782356	bot_m_35842@dateroot.com	hashed_pass	Anthony NO1	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:04:54.30206+01	male	bisexual	46	Luxembourg City	Luxembourg	https://res.cloudinary.com/do54j5dgq/image/upload/v1771261444/dating_app_photos/foaonnqigy3yumrabfjy.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
bfbf77c7-1f07-499d-bfdd-ef235db91fc6	bot_m_25336@dateroot.com	hashed_pass	Steven	f	2026-02-08 02:20:05.360391+01	Foodie ??	f	\N	\N	2026-02-16 18:30:29.288093+01	male	heterosexual	30	Dallas	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
7172cbb9-4cc9-488e-8d19-43c04e168031	bot_m_80957@dateroot.com	hashed_pass	Daniel	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-16 20:10:19.053523+01	male	heterosexual	58	London	United Kingdom	https://i.pravatar.cc/400?u=bot_m_80957@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
ffa83ce2-cdf9-4bf9-80b2-e1148c0e4ba2	bot_m_69631@dateroot.com	hashed_pass	Louisa Santos	f	2026-02-08 02:20:05.360391+01	\N	f	\N	\N	2026-02-16 18:42:15.334004+01	male	heterosexual	29	Manila	Philippines	https://i.pravatar.cc/400?u=bot_m_69631@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Muslim	No	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
30393e69-d59d-4a66-bea3-b9a3b857a389	bot_m_23130@dateroot.com	hashed_pass	Jason	f	2026-02-08 02:20:05.360391+01	Looking for something real.	f	\N	\N	2026-02-16 15:59:01.66872+01	male	heterosexual	58	Sheffield	United Kingdom	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Christian	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	190	86	Black	Brown	\N	\N	\N	\N
f47ac0ad-a690-40c7-8453-c4202cf47048	bot_m_14612@dateroot.com	hashed_pass	Robert	f	2026-02-08 02:20:05.360391+01	Tech guy ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	30	San Diego	\N	https://i.pravatar.cc/400?u=bot_m_14612@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
1b012a65-c7c3-47ff-844d-2f3140678327	bot_m_75617@dateroot.com	hashed_pass	Inna Love	f	2026-02-08 02:20:05.360391+01	I love everything retro—from vinyl records to mid-century furniture. I’m an interior designer who loves bringing the past into the present. Looking for someone who appreciates the classics.	f	\N	\N	2026-02-16 17:41:50.779259+01	female	heterosexual	35	Stockholm	Sweden	https://res.cloudinary.com/do54j5dgq/image/upload/v1771259950/dating_app_photos/qxwwnn79n2noyhpilvv8.webp	t	2026-02-08 02:20:05.360391+01	t	Relationship	University	Christian	Yes	Socially	\N	\N	{https://res.cloudinary.com/do54j5dgq/image/upload/v1771259955/dating_app_photos/ydnjlydys91tyrujrtff.webp,https://res.cloudinary.com/do54j5dgq/image/upload/v1771259965/dating_app_photos/jiqwjnupmac0cfuseufb.webp}	\N	\N	\N	\N	100	\N	0.00	f	0	0	176	60	Blonde	Blue	\N	\N	\N	\N
54a17d08-b868-4a28-bcb1-e0e1fb94cbb3	bot_m_76680@dateroot.com	hashed_pass	Jonathan	f	2026-02-08 02:20:05.360391+01	Traveler ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	24	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_76680@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
0d995383-832b-48be-8dbd-bc46984c94c4	bot_m_55171@dateroot.com	hashed_pass	Andrew	f	2026-02-08 02:20:05.360391+01	Gym and hiking ???	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	24	Chicago	\N	https://i.pravatar.cc/400?u=bot_m_55171@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
5b0cbb1a-74ae-4b39-aeff-8ccf8a1ef2f4	bot_m_9806@dateroot.com	hashed_pass	William	f	2026-02-08 02:20:05.360391+01	Gym and hiking ???	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	25	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_9806@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
d1a8adda-dc9f-41b5-9256-7283e12ac6ea	bot_m_33179@dateroot.com	hashed_pass	Ryan	f	2026-02-08 02:20:05.360391+01	Lets grab a drink ??	f	\N	\N	2026-02-16 16:00:44.051835+01	male	heterosexual	21	Chicago	USA	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	High School	Other	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	182	85	Blonde	Blue	\N	\N	\N	\N
bb3ce1ea-5bf9-4c83-ac06-da0e68c6c4d4	bot_m_15270@dateroot.com	hashed_pass	Michael	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-16 18:30:58.614754+01	male	heterosexual	23	San Diego	\N	\N	t	2026-02-08 02:20:05.360391+01	t	Relationship	Not specified	Private	No	Socially	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	Not specified	Not specified	\N	\N	\N	\N
ae8a0d53-d9cc-4838-912e-b0a9c24a9499	bot_m_73176@dateroot.com	hashed_pass	John	f	2026-02-08 02:20:05.360391+01	Entrepreneur ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	26	Los Angeles	\N	https://i.pravatar.cc/400?u=bot_m_73176@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
b0d35eac-fd09-4fbc-9349-03a345ca69bd	bot_m_44499@dateroot.com	hashed_pass	Thomas	f	2026-02-08 02:20:05.360391+01	Lets grab a drink ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	22	New York	\N	https://i.pravatar.cc/400?u=bot_m_44499@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
83e71e75-3d5a-4adc-99d7-f2ae28798cd5	bot_m_55446@dateroot.com	hashed_pass	William	f	2026-02-08 02:20:05.360391+01	Gym and hiking ???	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	28	New York	\N	https://i.pravatar.cc/400?u=bot_m_55446@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
2396aedc-f83e-44f7-b3f3-d1f95e3d64b1	bot_m_94262@dateroot.com	hashed_pass	Steven	f	2026-02-08 02:20:05.360391+01	Foodie ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	25	Dallas	\N	https://i.pravatar.cc/400?u=bot_m_94262@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
5fd53921-f9ea-4604-a599-b6f883272ad3	bot_m_45172@dateroot.com	hashed_pass	Timothy	f	2026-02-08 02:20:05.360391+01	Tech guy ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	33	San Jose	\N	https://i.pravatar.cc/400?u=bot_m_45172@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
84c3a728-2b5a-433b-8f48-c8982f4fcd55	bot_m_42989@dateroot.com	hashed_pass	James	f	2026-02-08 02:20:05.360391+01	Dog dad ??	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	33	Houston	\N	https://i.pravatar.cc/400?u=bot_m_42989@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
f5cf5d0d-4073-4cea-b0aa-1cb27d35cf33	bot_m_36637@dateroot.com	hashed_pass	Brandon Smith	f	2026-02-08 02:20:05.360391+01	Traveler ??	f	\N	\N	2026-02-16 17:46:41.515068+01	male	gay	31	Boston	USA	https://res.cloudinary.com/do54j5dgq/image/upload/v1771260271/dating_app_photos/diuwjfckzgh9t181gah7.webp	t	2026-02-08 02:20:05.360391+01	t	New Friends	High School	Christian	Yes	Frequently	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	184	80	Brown	Brown	\N	\N	\N	\N
aa8cfb98-801a-465f-986d-809b53a2379f	bot_m_31134@dateroot.com	hashed_pass	Daniel	f	2026-02-08 02:20:05.360391+01	Adventure awaits!	f	\N	\N	2026-02-08 02:20:05.360391+01	male	\N	23	Dallas	\N	https://i.pravatar.cc/400?u=bot_m_31134@dateroot.com	t	2026-02-08 02:20:05.360391+01	t	\N	\N	\N	\N	\N	\N	\N	{}	\N	\N	\N	\N	100	\N	0.00	f	0	0	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sent_gifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sent_gifts (id, sender_id, receiver_id, gift_id, created_at) FROM stdin;
fde5f9be-23b1-41e2-9227-662b0d3005e2	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	d004309a-5267-4af3-8216-3c5504ce5425	1b606f9b-a6c9-4161-85b5-1bbb17290a16	2026-03-01 06:40:01.256077
2c57e108-34d7-4ab3-988f-07bc4b446724	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	8807bf23-53b6-47f4-a6ba-3af774e3cea0	1f492164-1c05-4750-bbb6-2a124bf3e81b	2026-03-02 08:56:27.936564
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (id, user_id, stripe_customer_id, stripe_subscription_id, plan_type, status, started_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: support_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.support_messages (id, name, email, subject, message, created_at, status) FROM stdin;
c0942323-5d4a-42ed-930c-ed2a0899f1d1	vdgdg	ksosksoskkj@hotmail.com	vdvd	vdv vdv	2026-02-12 22:00:53.994127+01	unread
0b92921c-3d3e-437c-a695-92282318b2d8	vdgdg	acidpositive519@gmail.com	efwf	fwgwg	2026-02-20 17:39:24.23806+01	unread
\.


--
-- Data for Name: user_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_blocks (id, blocker_id, blocked_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_photos (id, user_id, photo_url, is_profile_pic, created_at, cloudinary_id) FROM stdin;
120	f35e090d-d8a0-437c-aae1-1735b9eb48cc	https://res.cloudinary.com/do54j5dgq/image/upload/v1771243950/dating_app_photos/vixg7zganwh4a169ymtq.webp	t	2026-02-16 13:13:36.026039	vixg7zganwh4a169ymtq
121	f35e090d-d8a0-437c-aae1-1735b9eb48cc	https://res.cloudinary.com/do54j5dgq/image/upload/v1771243950/dating_app_photos/mmbrfgimfc7hdpth3ou6.webp	f	2026-02-16 13:13:36.044599	mmbrfgimfc7hdpth3ou6
123	17a3a2a2-6c31-4614-8ea8-464254847786	https://i.pravatar.cc/400?u=bot_f_7915@dateroot.com	t	2026-02-16 13:18:56.128629	400?u=bot_f_7915@dateroot
124	4ede5d1d-fea1-44a7-9899-fc89bf583499	https://i.pravatar.cc/400?u=bot_f_63026@dateroot.com	t	2026-02-16 13:20:47.074207	400?u=bot_f_63026@dateroot
125	5157ac77-1580-4cdb-94ba-0778279c53b9	https://i.pravatar.cc/400?u=bot_f_53684@dateroot.com	t	2026-02-16 13:23:27.461391	400?u=bot_f_53684@dateroot
126	15d1840c-2532-4333-8c23-f98034b3d1c1	https://res.cloudinary.com/do54j5dgq/image/upload/v1771244687/dating_app_photos/mmgsy5ykwnkcqwakaux5.webp	t	2026-02-16 13:38:55.570779	mmgsy5ykwnkcqwakaux5
127	08fdbddf-8510-459c-b576-99151c904c53	https://res.cloudinary.com/do54j5dgq/image/upload/v1771245603/dating_app_photos/u3sxtmgcrjaxinqtwvm5.webp	t	2026-02-16 13:43:00.717969	u3sxtmgcrjaxinqtwvm5
128	f27d76a4-28c5-4728-ba00-48fc2451afee	https://i.pravatar.cc/400?u=bot_f_50807@dateroot.com	t	2026-02-16 13:45:12.738034	400?u=bot_f_50807@dateroot
142	4ea72160-dffc-44c3-aa67-38a3148d2deb	https://res.cloudinary.com/do54j5dgq/image/upload/v1771254310/dating_app_photos/ktdwso2fpdbymaujb5lb.webp	t	2026-02-16 16:06:29.738143	ktdwso2fpdbymaujb5lb
143	4ea72160-dffc-44c3-aa67-38a3148d2deb	https://res.cloudinary.com/do54j5dgq/image/upload/v1771254315/dating_app_photos/ez8hxqe2fyawhkuio6so.webp	f	2026-02-16 16:06:29.751662	ez8hxqe2fyawhkuio6so
145	46a4abc9-1562-4f46-becf-698bf579e998	https://res.cloudinary.com/do54j5dgq/image/upload/v1771254485/dating_app_photos/xtklqjeadnbkdwgtla2l.webp	t	2026-02-16 16:26:32.14558	xtklqjeadnbkdwgtla2l
146	4ebe117b-c139-4d37-a7f9-e86989172ef3	https://res.cloudinary.com/do54j5dgq/image/upload/v1771255691/dating_app_photos/vy4x1mmvucd1rt5jghmy.webp	t	2026-02-16 16:33:34.49561	vy4x1mmvucd1rt5jghmy
147	112e725b-6f5b-4f96-a049-a222be80b855	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256101/dating_app_photos/aeuzzghswmytx64oymtr.webp	t	2026-02-16 16:36:14.088266	aeuzzghswmytx64oymtr
148	9e67a469-a4e3-44b2-9060-c7b5809cab5c	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256253/dating_app_photos/wqech1cvvhlc8wkcg5h5.webp	t	2026-02-16 16:39:39.292858	wqech1cvvhlc8wkcg5h5
149	fd92da0f-75ca-4c92-b13a-097335a343c6	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256442/dating_app_photos/i3efnxktwwro9lvczg4r.webp	t	2026-02-16 16:43:20.970087	i3efnxktwwro9lvczg4r
150	5e3176b1-53c2-4846-9768-9217afceb9fb	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256713/dating_app_photos/e5jbgvetr9fbbwkpikad.webp	t	2026-02-16 16:47:10.397666	e5jbgvetr9fbbwkpikad
151	1230acac-7210-49d2-8323-27b7c0c31bbf	https://res.cloudinary.com/do54j5dgq/image/upload/v1771256949/dating_app_photos/qps8kgik6qxv92700qnn.webp	t	2026-02-16 16:50:27.845964	qps8kgik6qxv92700qnn
152	e8b2871b-184a-4228-a32d-1fb0eff39a8b	https://res.cloudinary.com/do54j5dgq/image/upload/v1771257132/dating_app_photos/kxsqdxwosjqbli5egm9b.webp	t	2026-02-16 16:53:11.533911	kxsqdxwosjqbli5egm9b
154	a3d26499-be2f-45af-9953-158b8b17ad9a	https://res.cloudinary.com/do54j5dgq/image/upload/v1771257280/dating_app_photos/e7himgd4vmvua1mekr45.webp	t	2026-02-16 17:00:01.327164	e7himgd4vmvua1mekr45
155	66eb3e5b-dcb6-4ce6-b64e-b2b7fcbd9270	https://i.pravatar.cc/400?u=bot_f_32595@dateroot.com	t	2026-02-16 17:11:31.661728	400?u=bot_f_32595@dateroot
156	b3375eaa-a371-417e-9c18-7b4c36786070	https://res.cloudinary.com/do54j5dgq/image/upload/v1771258340/dating_app_photos/gnp77kc21faklc0cu5qe.webp	t	2026-02-16 17:19:15.426448	gnp77kc21faklc0cu5qe
157	b3375eaa-a371-417e-9c18-7b4c36786070	https://res.cloudinary.com/do54j5dgq/image/upload/v1771258352/dating_app_photos/opsexgxic4gfjurpxig7.webp	f	2026-02-16 17:19:15.432811	opsexgxic4gfjurpxig7
158	fd450aea-b2e5-447c-8169-8a07a6db4afd	https://i.pravatar.cc/400?u=bot_f_55057@dateroot.com	t	2026-02-16 17:37:11.176728	400?u=bot_f_55057@dateroot
159	1b012a65-c7c3-47ff-844d-2f3140678327	https://res.cloudinary.com/do54j5dgq/image/upload/v1771259950/dating_app_photos/qxwwnn79n2noyhpilvv8.webp	t	2026-02-16 17:41:50.789098	qxwwnn79n2noyhpilvv8
160	1b012a65-c7c3-47ff-844d-2f3140678327	https://res.cloudinary.com/do54j5dgq/image/upload/v1771259955/dating_app_photos/ydnjlydys91tyrujrtff.webp	f	2026-02-16 17:41:50.790706	ydnjlydys91tyrujrtff
161	1b012a65-c7c3-47ff-844d-2f3140678327	https://res.cloudinary.com/do54j5dgq/image/upload/v1771259965/dating_app_photos/jiqwjnupmac0cfuseufb.webp	f	2026-02-16 17:41:50.791795	jiqwjnupmac0cfuseufb
162	f5cf5d0d-4073-4cea-b0aa-1cb27d35cf33	https://res.cloudinary.com/do54j5dgq/image/upload/v1771260271/dating_app_photos/diuwjfckzgh9t181gah7.webp	t	2026-02-16 17:46:41.522477	diuwjfckzgh9t181gah7
163	80634134-6662-452b-be5f-3541ad7cc9ec	https://i.pravatar.cc/400?u=bot_f_40500@dateroot.com	t	2026-02-16 17:53:55.511982	400?u=bot_f_40500@dateroot
164	c1619cfd-8992-469f-b7d9-357983a9af4b	https://res.cloudinary.com/do54j5dgq/image/upload/v1771261122/dating_app_photos/lk3v0sj0thhrrpyka3z8.webp	t	2026-02-16 18:01:19.394949	lk3v0sj0thhrrpyka3z8
165	25136cc9-c962-48d6-9019-97c65c782356	https://res.cloudinary.com/do54j5dgq/image/upload/v1771261444/dating_app_photos/foaonnqigy3yumrabfjy.webp	t	2026-02-16 18:04:54.323361	foaonnqigy3yumrabfjy
166	54d24948-5e79-4f5a-85c4-0603678116ad	https://i.pravatar.cc/400?u=bot_f_68123@dateroot.com	t	2026-02-16 18:06:41.591316	400?u=bot_f_68123@dateroot
167	0d5b43ed-32f3-4ed6-927f-08730e7a6316	https://i.pravatar.cc/400?u=bot_m_32774@dateroot.com	t	2026-02-16 18:12:07.812619	400?u=bot_m_32774@dateroot
168	18befac1-c1a9-4fb7-91ba-f6f1961c3ae3	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262046/dating_app_photos/itmapcjysflviqzroig2.webp	t	2026-02-16 18:15:20.178847	itmapcjysflviqzroig2
169	18befac1-c1a9-4fb7-91ba-f6f1961c3ae3	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262055/dating_app_photos/bx71gv026d2ph6dradcf.webp	f	2026-02-16 18:15:20.181522	bx71gv026d2ph6dradcf
170	93f5fab8-8ee3-41a5-8c70-5774f103383e	https://i.pravatar.cc/400?u=bot_m_35181@dateroot.com	t	2026-02-16 18:17:26.929622	400?u=bot_m_35181@dateroot
172	d2371d7c-268f-428a-97db-3951211eebeb	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262450/dating_app_photos/ydxgr6kpvb0dp5si7moy.webp	t	2026-02-16 18:23:17.217246	ydxgr6kpvb0dp5si7moy
173	43a0c596-d32a-49f7-9177-73daad4ccb67	https://res.cloudinary.com/do54j5dgq/image/upload/v1771262728/dating_app_photos/xaeeb4r3bqljlvxf6kka.webp	t	2026-02-16 18:26:23.399281	xaeeb4r3bqljlvxf6kka
174	e994d87d-2ef0-41a5-b14c-ed37dc113809	https://i.pravatar.cc/400?u=bot_m_7509@dateroot.com	t	2026-02-16 18:29:01.650809	400?u=bot_m_7509@dateroot
175	ffa83ce2-cdf9-4bf9-80b2-e1148c0e4ba2	https://i.pravatar.cc/400?u=bot_m_69631@dateroot.com	t	2026-02-16 18:42:15.342987	400?u=bot_m_69631@dateroot
176	1465a6aa-62cc-41d7-8758-8133af0b6f36	https://i.pravatar.cc/400?u=bot_m_68902@dateroot.com	t	2026-02-16 18:43:14.681663	400?u=bot_m_68902@dateroot
178	84e8f52d-3bbb-49e3-90bc-cfe7563dcc2b	https://res.cloudinary.com/do54j5dgq/image/upload/v1771263917/dating_app_photos/r5nxcm14j0odlfh7h1xv.webp	t	2026-02-16 18:46:42.11569	r5nxcm14j0odlfh7h1xv
179	d004309a-5267-4af3-8216-3c5504ce5425	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264118/dating_app_photos/gosjiuaylsupdd4xa9oz.webp	t	2026-02-16 18:49:18.374506	gosjiuaylsupdd4xa9oz
180	22c98c03-fc65-4275-9ff5-f190eeb36879	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264332/dating_app_photos/d7tachedktjynwuxpid4.webp	t	2026-02-16 18:53:10.676093	d7tachedktjynwuxpid4
181	3696f785-b546-49ac-833b-80307e491325	https://res.cloudinary.com/do54j5dgq/image/upload/v1771264900/dating_app_photos/ftc1uewowm1cjrpgcuxk.webp	t	2026-02-16 19:02:40.253232	ftc1uewowm1cjrpgcuxk
183	e04e8dfa-a7f2-4d4a-9fa2-d4b8c52d4334	https://i.pravatar.cc/400?u=bot_m_14521@dateroot.com	t	2026-02-16 19:46:50.72025	400?u=bot_m_14521@dateroot
185	8ba1ad2f-47b6-4b0f-9490-8bbb2ecc5a79	https://res.cloudinary.com/do54j5dgq/image/upload/v1771268621/dating_app_photos/z5ecwdpsepuk1n3pppkw.webp	t	2026-02-16 20:07:14.499053	z5ecwdpsepuk1n3pppkw
186	10d9bb78-1fe4-4937-99cc-320770ef6f25	https://i.pravatar.cc/400?u=bot_f_90957@dateroot.com	t	2026-02-16 20:08:14.200313	400?u=bot_f_90957@dateroot
187	97cb730b-5331-492a-aa57-fa8244e5a049	https://i.pravatar.cc/400?u=bot_f_87377@dateroot.com	t	2026-02-16 20:09:01.360244	400?u=bot_f_87377@dateroot
188	7172cbb9-4cc9-488e-8d19-43c04e168031	https://i.pravatar.cc/400?u=bot_m_80957@dateroot.com	t	2026-02-16 20:10:19.059465	400?u=bot_m_80957@dateroot
189	23f43d13-4ba0-41aa-b608-0594775e99ee	https://i.pravatar.cc/400?u=bot_f_52003@dateroot.com	t	2026-02-16 20:40:51.623659	400?u=bot_f_52003@dateroot
190	f23685c7-29af-4fa6-a3dd-e282aaac9640	https://i.pravatar.cc/400?u=bot_f_48025@dateroot.com	t	2026-02-16 20:41:39.644826	400?u=bot_f_48025@dateroot
202	2489129e-b6e1-4664-a92f-745dd7c23bb9	https://res.cloudinary.com/do54j5dgq/image/upload/v1771177583/dating_app_photos/q5p6f0mga7k5p6wwug6i.webp	t	2026-02-19 02:03:07.286882	q5p6f0mga7k5p6wwug6i
205	fbd1a953-dd2e-44a2-8a2e-b5b67ea12a58	https://res.cloudinary.com/do54j5dgq/image/upload/v1771876561/dating_app_photos/bxjwbpguncbuubuqzung.webp	t	2026-03-01 06:39:37.509656	bxjwbpguncbuubuqzung
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, created_at) FROM stdin;
\.


--
-- Name: chat_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_reports_id_seq', 23, true);


--
-- Name: profile_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profile_images_id_seq', 1, false);


--
-- Name: profile_visits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profile_visits_id_seq', 3058, true);


--
-- Name: user_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_blocks_id_seq', 28, true);


--
-- Name: user_photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_photos_id_seq', 205, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: affiliate_commissions affiliate_commissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT affiliate_commissions_pkey PRIMARY KEY (id);


--
-- Name: blocked_ips blocked_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocked_ips
    ADD CONSTRAINT blocked_ips_pkey PRIMARY KEY (ip_address);


--
-- Name: chat_reports chat_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_reports
    ADD CONSTRAINT chat_reports_pkey PRIMARY KEY (id);


--
-- Name: drip_campaigns drip_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drip_campaigns
    ADD CONSTRAINT drip_campaigns_pkey PRIMARY KEY (user_id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_user_id_favorited_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_favorited_user_id_key UNIQUE (user_id, favorited_user_id);


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: friends friends_sender_id_receiver_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_sender_id_receiver_id_key UNIQUE (sender_id, receiver_id);


--
-- Name: gifts gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gifts
    ADD CONSTRAINT gifts_pkey PRIMARY KEY (id);


--
-- Name: hidden_chats hidden_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hidden_chats
    ADD CONSTRAINT hidden_chats_pkey PRIMARY KEY (user_id, hidden_user_id);


--
-- Name: lobby_messages lobby_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lobby_messages
    ADD CONSTRAINT lobby_messages_pkey PRIMARY KEY (id);


--
-- Name: manual_payments manual_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manual_payments
    ADD CONSTRAINT manual_payments_pkey PRIMARY KEY (id);


--
-- Name: message_limits message_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_limits
    ADD CONSTRAINT message_limits_pkey PRIMARY KEY (id);


--
-- Name: payout_requests payout_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payout_requests
    ADD CONSTRAINT payout_requests_pkey PRIMARY KEY (id);


--
-- Name: private_messages private_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_pkey PRIMARY KEY (id);


--
-- Name: profile_images profile_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_images
    ADD CONSTRAINT profile_images_pkey PRIMARY KEY (id);


--
-- Name: profile_visits profile_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_visits
    ADD CONSTRAINT profile_visits_pkey PRIMARY KEY (id);


--
-- Name: profile_visits profile_visits_visitor_id_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_visits
    ADD CONSTRAINT profile_visits_visitor_id_profile_id_key UNIQUE (visitor_id, profile_id);


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: sent_gifts sent_gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sent_gifts
    ADD CONSTRAINT sent_gifts_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: support_messages support_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_pkey PRIMARY KEY (id);


--
-- Name: message_limits unique_message_limit_composite; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_limits
    ADD CONSTRAINT unique_message_limit_composite UNIQUE (user_id, chat_type, conversation_id);


--
-- Name: user_blocks user_blocks_blocker_id_blocked_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_blocker_id_blocked_id_key UNIQUE (blocker_id, blocked_id);


--
-- Name: user_blocks user_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_pkey PRIMARY KEY (id);


--
-- Name: user_photos user_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_photos
    ADD CONSTRAINT user_photos_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_active_users; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_active_users ON public.profiles USING btree (id, display_name, photo_url) WHERE (is_online = true);


--
-- Name: idx_drip_active_next; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drip_active_next ON public.drip_campaigns USING btree (is_active, next_message_at);


--
-- Name: idx_drip_next; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drip_next ON public.drip_campaigns USING btree (next_message_at) WHERE (is_active = true);


--
-- Name: idx_favorites_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_favorites_user_id ON public.favorites USING btree (user_id);


--
-- Name: idx_friends_receiver_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friends_receiver_status ON public.friends USING btree (receiver_id, status);


--
-- Name: idx_friends_sender_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friends_sender_status ON public.friends USING btree (sender_id, status);


--
-- Name: idx_lobby_messages_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lobby_messages_created_at ON public.lobby_messages USING btree (created_at DESC);


--
-- Name: idx_online_lobby_fast; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_online_lobby_fast ON public.profiles USING btree (id, display_name, photo_url, gender, age) WHERE ((is_online = true) AND (is_banned = false) AND (is_setup = true));


--
-- Name: idx_private_messages_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_messages_conversation ON public.private_messages USING btree (conversation_id);


--
-- Name: idx_private_messages_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_messages_receiver ON public.private_messages USING btree (receiver_id);


--
-- Name: idx_private_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_messages_sender ON public.private_messages USING btree (sender_id);


--
-- Name: idx_profile_visits_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profile_visits_profile_id ON public.profile_visits USING btree (profile_id);


--
-- Name: idx_profiles_browse; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_browse ON public.profiles USING btree (gender, age, town);


--
-- Name: idx_profiles_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_email ON public.profiles USING btree (email);


--
-- Name: idx_profiles_gender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_gender ON public.profiles USING btree (gender);


--
-- Name: idx_profiles_is_online; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_is_online ON public.profiles USING btree (is_online);


--
-- Name: idx_subscriptions_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscriptions_active ON public.subscriptions USING btree (user_id, status, expires_at);


--
-- Name: idx_user_blocks_blocked_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_blocks_blocked_id ON public.user_blocks USING btree (blocked_id);


--
-- Name: idx_user_blocks_blocker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_blocks_blocker ON public.user_blocks USING btree (blocker_id);


--
-- Name: profiles profiles_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


--
-- Name: subscriptions subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


--
-- Name: affiliate_commissions affiliate_commissions_affiliate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT affiliate_commissions_affiliate_id_fkey FOREIGN KEY (affiliate_id) REFERENCES public.profiles(id);


--
-- Name: affiliate_commissions affiliate_commissions_manual_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT affiliate_commissions_manual_payment_id_fkey FOREIGN KEY (manual_payment_id) REFERENCES public.manual_payments(id);


--
-- Name: affiliate_commissions affiliate_commissions_referred_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT affiliate_commissions_referred_user_id_fkey FOREIGN KEY (referred_user_id) REFERENCES public.profiles(id);


--
-- Name: chat_reports chat_reports_reported_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_reports
    ADD CONSTRAINT chat_reports_reported_user_id_fkey FOREIGN KEY (reported_id) REFERENCES public.profiles(id);


--
-- Name: chat_reports chat_reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_reports
    ADD CONSTRAINT chat_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id);


--
-- Name: drip_campaigns drip_campaigns_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drip_campaigns
    ADD CONSTRAINT drip_campaigns_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_favorited_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_favorited_user_id_fkey FOREIGN KEY (favorited_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_visits fk_profile; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_visits
    ADD CONSTRAINT fk_profile FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_visits fk_visitor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_visits
    ADD CONSTRAINT fk_visitor FOREIGN KEY (visitor_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: friends friendships_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friendships_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: friends friendships_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friendships_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: lobby_messages lobby_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lobby_messages
    ADD CONSTRAINT lobby_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id);


--
-- Name: manual_payments manual_payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manual_payments
    ADD CONSTRAINT manual_payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id);


--
-- Name: message_limits message_limits_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_limits
    ADD CONSTRAINT message_limits_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: payout_requests payout_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payout_requests
    ADD CONSTRAINT payout_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: private_messages private_messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id);


--
-- Name: private_messages private_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id);


--
-- Name: profile_images profile_images_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_images
    ADD CONSTRAINT profile_images_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_referred_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_referred_by_fkey FOREIGN KEY (referred_by) REFERENCES public.profiles(id);


--
-- Name: sent_gifts sent_gifts_gift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sent_gifts
    ADD CONSTRAINT sent_gifts_gift_id_fkey FOREIGN KEY (gift_id) REFERENCES public.gifts(id) ON DELETE CASCADE;


--
-- Name: sent_gifts sent_gifts_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sent_gifts
    ADD CONSTRAINT sent_gifts_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: sent_gifts sent_gifts_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sent_gifts
    ADD CONSTRAINT sent_gifts_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_blocks user_blocks_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_blocks user_blocks_blocker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: friends; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict fJDGMH1JGDJDSSw1fDR5jF2nYJBnRhz1IPUn1WP7dSFg8odmMO9Kc9fmaBKbsbO

