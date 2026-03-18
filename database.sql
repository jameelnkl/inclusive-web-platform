--
-- PostgreSQL database dump
--

\restrict VeIInfPnabaSdCzNHygDFMZq9MZBATwBL1wWwvxkSQK5gn7d6xvoTHPFWKGiLnk

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
-- Name: application_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.application_status AS ENUM (
    'pending',
    'in_review',
    'accepted',
    'rejected'
);


ALTER TYPE public.application_status OWNER TO postgres;

--
-- Name: rating_value; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.rating_value AS ENUM (
    'feasible',
    'help',
    'avoid'
);


ALTER TYPE public.rating_value OWNER TO postgres;

--
-- Name: requirement_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.requirement_type AS ENUM (
    'must',
    'optional'
);


ALTER TYPE public.requirement_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body_part_id integer,
    code character varying(50) NOT NULL,
    label character varying(255) NOT NULL,
    category character varying(100),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.abilities OWNER TO postgres;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    candidate_id uuid NOT NULL,
    job_role_id uuid NOT NULL,
    status public.application_status DEFAULT 'pending'::public.application_status NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: body_parts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.body_parts (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name_en character varying(100) NOT NULL,
    name_fr character varying(100),
    name_ar character varying(100),
    description text,
    severity_level smallint,
    CONSTRAINT body_parts_severity_level_check CHECK ((severity_level = ANY (ARRAY[1, 2])))
);


ALTER TABLE public.body_parts OWNER TO postgres;

--
-- Name: body_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.body_parts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.body_parts_id_seq OWNER TO postgres;

--
-- Name: body_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.body_parts_id_seq OWNED BY public.body_parts.id;


--
-- Name: candidate_abilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidate_abilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    candidate_id uuid NOT NULL,
    ability_id uuid NOT NULL,
    level smallint,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT candidate_abilities_level_check CHECK (((level >= 0) AND (level <= 5)))
);


ALTER TABLE public.candidate_abilities OWNER TO postgres;

--
-- Name: candidates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(50),
    location character varying(255),
    bio text,
    education_level character varying(100),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.candidates OWNER TO postgres;

--
-- Name: employers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    company_name character varying(255) NOT NULL,
    sector character varying(100),
    location character varying(255),
    contact_name character varying(255),
    contact_phone character varying(50),
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.employers OWNER TO postgres;

--
-- Name: job_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employer_id uuid,
    title character varying(255) NOT NULL,
    name_fr character varying(255),
    name_ar character varying(255),
    description text,
    is_template boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.job_roles OWNER TO postgres;

--
-- Name: task_assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_assessments (
    id integer NOT NULL,
    job_role_id uuid NOT NULL,
    task_id uuid NOT NULL,
    body_part_id integer NOT NULL,
    rating public.rating_value NOT NULL,
    notes text
);


ALTER TABLE public.task_assessments OWNER TO postgres;

--
-- Name: task_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_assessments_id_seq OWNER TO postgres;

--
-- Name: task_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_assessments_id_seq OWNED BY public.task_assessments.id;


--
-- Name: task_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_categories (
    id integer NOT NULL,
    name_fr character varying(255),
    name_en character varying(255) NOT NULL,
    name_ar character varying(255)
);


ALTER TABLE public.task_categories OWNER TO postgres;

--
-- Name: task_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_categories_id_seq OWNER TO postgres;

--
-- Name: task_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_categories_id_seq OWNED BY public.task_categories.id;


--
-- Name: task_requirements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_requirements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    ability_id uuid NOT NULL,
    required_level smallint,
    requirement_type public.requirement_type DEFAULT 'must'::public.requirement_type NOT NULL,
    CONSTRAINT task_requirements_required_level_check CHECK (((required_level >= 0) AND (required_level <= 5)))
);


ALTER TABLE public.task_requirements OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_role_id uuid,
    category_id integer,
    parent_task_id uuid,
    name character varying(255) NOT NULL,
    name_fr character varying(255),
    name_ar character varying(255),
    description text,
    is_optional boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['candidate'::character varying, 'employer'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: body_parts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_parts ALTER COLUMN id SET DEFAULT nextval('public.body_parts_id_seq'::regclass);


--
-- Name: task_assessments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments ALTER COLUMN id SET DEFAULT nextval('public.task_assessments_id_seq'::regclass);


--
-- Name: task_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_categories ALTER COLUMN id SET DEFAULT nextval('public.task_categories_id_seq'::regclass);


--
-- Data for Name: abilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abilities (id, body_part_id, code, label, category, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, candidate_id, job_role_id, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: body_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.body_parts (id, code, name_en, name_fr, name_ar, description, severity_level) FROM stdin;
1	H1_main	Hand type 1	Main H1	اليد ن1	Single hand impairment - type 1	1
2	H1_avant_bras	Forearm type 1	Avant-bras H1	الساعد ن1	Forearm impairment - type 1	1
3	H1_bras	Arm type 1	Bras H1	الذراع ن1	Full arm impairment - type 1	1
4	H2_mains	Hands type 2	Mains H2	اليدان ن2	Both hands impairment - type 2	2
5	H2_avant_bras	Forearms type 2	Avant-bras H2	الساعدان ن2	Both forearms impairment - type 2	2
6	H2_bras	Arms type 2	Bras H2	الذراعان ن2	Both arms impairment - type 2	2
7	H1_cheville	Ankle type 1	Cheville H1	الكاحل ن1	Single ankle impairment - type 1	1
8	H1_cheville_jambe	Ankle & leg type 1	Cheville & jambe H1	الكاحل والساق ن1	Ankle and leg impairment - type 1	1
9	H1_pieds	Feet type 1	Pieds H1	القدمان ن1	Feet impairment - type 1	1
10	H2_chevilles	Ankles type 2	Chevilles H2	الكاحلان ن2	Both ankles impairment - type 2	2
11	H2_chevilles_jambes	Ankles & legs type 2	Chevilles & jambes H2	الكاحلان والساقان ن2	Both ankles and legs impairment - type 2	2
12	H2_jambes	Legs type 2	Jambes H2	الساقان ن2	Both legs impairment - type 2	2
13	H1_AVC	Stroke (CVA) type 1	AVC H1	سكتة دماغية ن1	Cerebrovascular accident (stroke) - type 1	1
14	H_fauteuil	Wheelchair	Fauteuil roulant	كرسي متحرك	Wheelchair user - standard position	\N
15	H_fauteuil_ventre	Wheelchair - prone	Fauteuil ventre	كرسي متحرك - بطن	Wheelchair user - ventral/prone position	\N
16	H_fauteuil_sangl	Wheelchair - strapped	Fauteuil sanglé	كرسي متحرك - مقيد	Wheelchair user - strapped/secured position	\N
17	H2_pieds	Feet type 2	Pieds H2	القدمان ن2	Both feet impairment - type 2	2
\.


--
-- Data for Name: candidate_abilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.candidate_abilities (id, candidate_id, ability_id, level, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: candidates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.candidates (id, user_id, full_name, phone, location, bio, education_level, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: employers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employers (id, user_id, company_name, sector, location, contact_name, contact_phone, updated_at) FROM stdin;
\.


--
-- Data for Name: job_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_roles (id, employer_id, title, name_fr, name_ar, description, is_template, created_at, updated_at) FROM stdin;
00000000-0000-0000-0000-000000000001	\N	Chocolaterie	Confiserie - Chocolaterie	الحلويات - مصنع الشوكولاتة	Confectionary and chocolate production worker	t	2026-03-18 18:19:27.052124	2026-03-18 18:19:27.052124
00000000-0000-0000-0000-000000000002	\N	Glacerie	Glacier	صانع الآيس كريم	Ice cream maker	t	2026-03-18 18:19:27.052124	2026-03-18 18:19:27.052124
00000000-0000-0000-0000-000000000003	\N	Bakery Pastry	Boulangerie patisserie	مخبز المعجنات	Bakery and pastry worker	t	2026-03-18 18:19:27.052124	2026-03-18 18:19:27.052124
\.


--
-- Data for Name: task_assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_assessments (id, job_role_id, task_id, body_part_id, rating, notes) FROM stdin;
16452	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	1	feasible	\N
16453	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	1	feasible	\N
16454	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	1	feasible	\N
16455	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	1	feasible	\N
16456	00000000-0000-0000-0000-000000000001	374d5fe3-5ef3-4bbd-8581-6c845933d0ef	1	feasible	\N
16457	00000000-0000-0000-0000-000000000001	b97752de-0609-49fe-be07-67f954430fe4	1	feasible	\N
16458	00000000-0000-0000-0000-000000000001	a385553c-89c5-4f38-94eb-c98254d7d1a3	1	feasible	\N
16459	00000000-0000-0000-0000-000000000001	fccfe5f0-2d1a-48a2-a625-ee84fdb09dea	1	feasible	\N
16460	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	1	feasible	\N
16461	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	1	feasible	\N
16462	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	1	feasible	\N
16463	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	1	feasible	\N
16464	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	1	feasible	\N
16465	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	1	feasible	\N
16466	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	1	feasible	\N
16467	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	1	feasible	\N
16468	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	1	feasible	\N
16469	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	1	feasible	\N
16470	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	1	feasible	\N
16471	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	1	feasible	\N
16472	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	1	feasible	\N
16473	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	1	feasible	\N
16474	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	1	feasible	\N
16475	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	1	feasible	\N
16476	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	1	feasible	\N
16477	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	1	feasible	\N
16478	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	1	feasible	\N
16479	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	1	feasible	\N
16480	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	1	feasible	\N
16481	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	1	feasible	\N
16482	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	1	feasible	\N
16483	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	1	feasible	\N
16484	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	1	feasible	\N
16485	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	1	feasible	\N
16486	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	1	feasible	\N
16487	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	1	feasible	\N
16488	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	1	feasible	\N
16489	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	1	feasible	\N
16490	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	1	feasible	\N
16491	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	1	feasible	\N
16492	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	1	feasible	\N
16493	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	1	feasible	\N
16494	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	1	feasible	\N
16495	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	1	feasible	\N
16496	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	1	feasible	\N
16497	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	1	feasible	\N
16498	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	1	feasible	\N
16499	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	1	feasible	\N
16500	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	1	feasible	\N
16501	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	1	feasible	\N
16502	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	1	help	\N
16503	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	1	feasible	\N
16504	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	1	feasible	\N
16505	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	1	feasible	\N
16506	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	1	feasible	\N
16507	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	1	feasible	\N
16508	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	1	feasible	\N
16509	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	1	feasible	\N
16510	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	1	feasible	\N
16511	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	1	feasible	\N
16512	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	1	feasible	\N
16513	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	1	feasible	\N
16514	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	1	feasible	\N
16515	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	1	feasible	\N
16516	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	1	feasible	\N
16517	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	1	feasible	\N
16518	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	1	feasible	\N
16519	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	1	feasible	\N
16520	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	1	feasible	\N
16521	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	1	feasible	\N
16522	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	1	feasible	\N
16523	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	1	feasible	\N
16524	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	1	feasible	\N
16525	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	1	feasible	\N
16526	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	1	feasible	\N
16527	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	1	feasible	\N
16528	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	1	feasible	\N
16529	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	1	feasible	\N
16530	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	1	feasible	\N
16531	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	1	feasible	\N
16532	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	1	feasible	\N
16533	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	2	feasible	\N
16534	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	2	feasible	\N
16535	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	2	feasible	\N
16536	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	2	feasible	\N
16537	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	2	feasible	\N
16538	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	2	feasible	\N
16539	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	2	feasible	\N
16540	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	2	feasible	\N
16541	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	2	feasible	\N
16542	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	2	feasible	\N
16543	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	2	feasible	\N
16544	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	2	feasible	\N
16545	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	2	feasible	\N
16546	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	2	feasible	\N
16547	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	2	feasible	\N
16548	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	2	feasible	\N
16549	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	2	feasible	\N
16550	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	2	feasible	\N
16551	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	2	feasible	\N
16552	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	2	feasible	\N
16553	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	2	feasible	\N
16554	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	2	feasible	\N
16555	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	2	feasible	\N
16556	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	2	feasible	\N
16557	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	2	feasible	\N
16558	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	2	feasible	\N
16559	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	2	feasible	\N
16560	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	2	feasible	\N
16561	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	2	feasible	\N
16562	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	2	feasible	\N
16563	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	2	feasible	\N
16564	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	2	feasible	\N
16565	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	2	feasible	\N
16566	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	2	feasible	\N
16567	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	2	feasible	\N
16568	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	2	feasible	\N
16569	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	2	feasible	\N
16570	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	2	feasible	\N
16571	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	2	feasible	\N
16572	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	2	feasible	\N
16573	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	2	feasible	\N
16574	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	2	feasible	\N
16575	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	2	feasible	\N
16576	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	2	feasible	\N
16577	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	2	feasible	\N
16578	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	2	feasible	\N
16579	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	2	feasible	\N
16580	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	2	feasible	\N
16581	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	2	feasible	\N
16582	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	2	feasible	\N
16583	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	2	help	\N
16584	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	2	feasible	\N
16585	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	2	feasible	\N
16586	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	2	feasible	\N
16587	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	2	feasible	\N
16588	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	2	feasible	\N
16589	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	2	feasible	\N
16590	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	2	feasible	\N
16591	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	2	feasible	\N
16592	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	2	feasible	\N
16593	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	2	feasible	\N
16594	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	2	feasible	\N
16595	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	2	feasible	\N
16596	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	2	feasible	\N
16597	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	2	feasible	\N
16598	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	2	feasible	\N
16599	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	2	feasible	\N
16600	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	2	feasible	\N
16601	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	2	feasible	\N
16602	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	2	feasible	\N
16603	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	2	feasible	\N
16604	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	2	feasible	\N
16605	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	2	feasible	\N
16606	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	2	feasible	\N
16607	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	2	feasible	\N
16608	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	2	feasible	\N
16609	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	2	feasible	\N
16610	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	2	feasible	\N
16611	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	2	feasible	\N
16612	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	2	feasible	\N
16613	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	2	feasible	\N
16614	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	3	feasible	\N
16615	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	3	feasible	\N
16616	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	3	feasible	\N
16617	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	3	feasible	\N
16618	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	3	feasible	\N
16619	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	3	feasible	\N
16620	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	3	feasible	\N
16621	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	3	feasible	\N
16622	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	3	feasible	\N
16623	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	3	feasible	\N
16624	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	3	feasible	\N
16625	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	3	feasible	\N
16626	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	3	help	\N
16627	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	3	feasible	\N
16628	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	3	feasible	\N
16629	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	3	feasible	\N
16630	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	3	feasible	\N
16631	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	3	feasible	\N
16632	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	3	feasible	\N
16633	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	3	feasible	\N
16634	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	3	feasible	\N
16635	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	3	feasible	\N
16636	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	3	feasible	\N
16637	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	3	feasible	\N
16638	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	3	feasible	\N
16639	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	3	feasible	\N
16640	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	3	feasible	\N
16641	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	3	feasible	\N
16642	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	3	feasible	\N
16643	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	3	feasible	\N
16644	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	3	feasible	\N
16645	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	3	feasible	\N
16646	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	3	feasible	\N
16647	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	3	feasible	\N
16648	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	3	feasible	\N
16649	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	3	feasible	\N
16650	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	3	feasible	\N
16651	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	3	feasible	\N
16652	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	3	feasible	\N
16653	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	3	feasible	\N
16654	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	3	feasible	\N
16655	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	3	feasible	\N
16656	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	3	feasible	\N
16657	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	3	feasible	\N
16658	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	3	feasible	\N
16659	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	3	feasible	\N
16660	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	3	feasible	\N
16661	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	3	feasible	\N
16662	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	3	feasible	\N
16663	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	3	feasible	\N
16664	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	3	help	\N
16665	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	3	feasible	\N
16666	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	3	feasible	\N
16667	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	3	feasible	\N
16668	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	3	feasible	\N
16669	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	3	feasible	\N
16670	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	3	feasible	\N
16671	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	3	feasible	\N
16672	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	3	feasible	\N
16673	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	3	feasible	\N
16674	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	3	feasible	\N
16675	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	3	feasible	\N
16676	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	3	feasible	\N
16677	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	3	feasible	\N
16678	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	3	feasible	\N
16679	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	3	feasible	\N
16680	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	3	feasible	\N
16681	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	3	feasible	\N
16682	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	3	feasible	\N
16683	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	3	feasible	\N
16684	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	3	feasible	\N
16685	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	3	feasible	\N
16686	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	3	feasible	\N
16687	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	3	feasible	\N
16688	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	3	feasible	\N
16689	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	3	feasible	\N
16690	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	3	feasible	\N
16691	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	3	feasible	\N
16692	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	3	feasible	\N
16693	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	3	feasible	\N
16694	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	3	feasible	\N
16695	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	4	feasible	\N
16696	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	4	feasible	\N
16697	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	4	feasible	\N
16698	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	4	feasible	\N
16699	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	4	feasible	\N
16700	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	4	help	\N
16701	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	4	feasible	\N
16702	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	4	feasible	\N
16703	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	4	feasible	\N
16704	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	4	feasible	\N
16705	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	4	feasible	\N
16706	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	4	feasible	\N
16707	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	4	feasible	\N
16708	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	4	feasible	\N
16709	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	4	feasible	\N
16710	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	4	feasible	\N
16711	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	4	feasible	\N
16712	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	4	feasible	\N
16713	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	4	feasible	\N
16714	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	4	feasible	\N
16715	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	4	feasible	\N
16716	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	4	feasible	\N
16717	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	4	feasible	\N
16718	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	4	help	\N
16719	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	4	help	\N
16720	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	4	help	\N
16721	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	4	help	\N
16722	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	4	help	\N
16723	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	4	help	\N
16724	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	4	help	\N
16725	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	4	help	\N
16726	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	4	help	\N
16727	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	4	feasible	\N
16728	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	4	help	\N
16729	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	4	feasible	\N
16730	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	4	feasible	\N
16731	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	4	feasible	\N
16732	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	4	help	\N
16733	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	4	feasible	\N
16734	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	4	help	\N
16735	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	4	help	\N
16736	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	4	help	\N
16737	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	4	help	\N
16738	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	4	help	\N
16739	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	4	help	\N
16740	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	4	feasible	\N
16741	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	4	help	\N
16742	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	4	help	\N
16743	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	4	help	\N
16744	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	4	help	\N
16745	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	4	help	\N
16746	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	4	help	\N
16747	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	4	help	\N
16748	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	4	help	\N
16749	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	4	feasible	\N
16750	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	4	help	\N
16751	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	4	help	\N
16752	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	4	feasible	\N
16753	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	4	feasible	\N
16754	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	4	feasible	\N
16755	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	4	feasible	\N
16756	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	4	feasible	\N
16757	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	4	feasible	\N
16758	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	4	feasible	\N
16759	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	4	help	\N
16760	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	4	help	\N
16761	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	4	feasible	\N
16762	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	4	help	\N
16763	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	4	help	\N
16764	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	4	feasible	\N
16765	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	4	feasible	\N
16766	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	4	feasible	\N
16767	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	4	feasible	\N
16768	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	4	feasible	\N
16769	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	4	feasible	\N
16770	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	4	feasible	\N
16771	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	4	feasible	\N
16772	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	4	help	\N
16773	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	4	help	\N
16774	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	4	help	\N
16775	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	4	help	\N
16776	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	5	feasible	\N
16777	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	5	feasible	\N
16778	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	5	feasible	\N
16779	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	5	feasible	\N
16780	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	5	feasible	\N
16781	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	5	help	\N
16782	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	5	feasible	\N
16783	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	5	feasible	\N
16784	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	5	feasible	\N
16785	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	5	feasible	\N
16786	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	5	feasible	\N
16787	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	5	feasible	\N
16788	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	5	feasible	\N
16789	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	5	feasible	\N
16790	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	5	feasible	\N
16791	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	5	feasible	\N
16792	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	5	feasible	\N
16793	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	5	feasible	\N
16794	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	5	feasible	\N
16795	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	5	feasible	\N
16796	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	5	feasible	\N
16797	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	5	feasible	\N
16798	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	5	feasible	\N
16799	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	5	help	\N
16800	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	5	help	\N
16801	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	5	help	\N
16802	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	5	help	\N
16803	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	5	help	\N
16804	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	5	help	\N
16805	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	5	help	\N
16806	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	5	help	\N
16807	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	5	help	\N
16808	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	5	feasible	\N
16809	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	5	help	\N
16810	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	5	feasible	\N
16811	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	5	feasible	\N
16812	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	5	feasible	\N
16813	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	5	help	\N
16814	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	5	feasible	\N
16815	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	5	help	\N
16816	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	5	help	\N
16817	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	5	help	\N
16818	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	5	help	\N
16819	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	5	help	\N
16820	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	5	help	\N
16821	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	5	feasible	\N
16822	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	5	help	\N
16823	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	5	help	\N
16824	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	5	help	\N
16825	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	5	help	\N
16826	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	5	help	\N
16827	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	5	help	\N
16828	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	5	help	\N
16829	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	5	help	\N
16830	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	5	feasible	\N
16831	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	5	help	\N
16832	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	5	help	\N
16833	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	5	feasible	\N
16834	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	5	feasible	\N
16835	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	5	feasible	\N
16836	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	5	feasible	\N
16837	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	5	feasible	\N
16838	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	5	feasible	\N
16839	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	5	feasible	\N
16840	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	5	help	\N
16841	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	5	help	\N
16842	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	5	feasible	\N
16843	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	5	help	\N
16844	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	5	help	\N
16845	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	5	feasible	\N
16846	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	5	feasible	\N
16847	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	5	feasible	\N
16848	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	5	feasible	\N
16849	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	5	feasible	\N
16850	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	5	feasible	\N
16851	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	5	feasible	\N
16852	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	5	feasible	\N
16853	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	5	help	\N
16854	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	5	help	\N
16855	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	5	help	\N
16856	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	5	help	\N
16857	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	6	feasible	\N
16858	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	6	feasible	\N
16859	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	6	feasible	\N
16860	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	6	feasible	\N
16861	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	6	feasible	\N
16862	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	6	help	\N
16863	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	6	feasible	\N
16864	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	6	feasible	\N
16865	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	6	help	\N
16866	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	6	help	\N
16867	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	6	feasible	\N
16868	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	6	help	\N
16869	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	6	help	\N
16870	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	6	help	\N
16871	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	6	help	\N
16872	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	6	help	\N
16873	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	6	feasible	\N
16874	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	6	feasible	\N
16875	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	6	feasible	\N
16876	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	6	feasible	\N
16877	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	6	feasible	\N
16878	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	6	help	\N
16879	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	6	feasible	\N
16880	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	6	help	\N
16881	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	6	help	\N
16882	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	6	help	\N
16883	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	6	help	\N
16884	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	6	help	\N
16885	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	6	help	\N
16886	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	6	help	\N
16887	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	6	help	\N
16888	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	6	help	\N
16889	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	6	help	\N
16890	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	6	help	\N
16891	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	6	help	\N
16892	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	6	help	\N
16893	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	6	help	\N
16894	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	6	help	\N
16895	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	6	help	\N
16896	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	6	help	\N
16897	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	6	help	\N
16898	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	6	help	\N
16899	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	6	help	\N
16900	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	6	help	\N
16901	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	6	help	\N
16902	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	6	help	\N
16903	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	6	help	\N
16904	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	6	help	\N
16905	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	6	help	\N
16906	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	6	help	\N
16907	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	6	help	\N
16908	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	6	help	\N
16909	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	6	help	\N
16910	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	6	help	\N
16911	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	6	help	\N
16912	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	6	help	\N
16913	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	6	help	\N
16914	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	6	feasible	\N
16915	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	6	help	\N
16916	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	6	feasible	\N
16917	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	6	feasible	\N
16918	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	6	feasible	\N
16919	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	6	feasible	\N
16920	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	6	feasible	\N
16921	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	6	help	\N
16922	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	6	help	\N
16923	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	6	feasible	\N
16924	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	6	help	\N
16925	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	6	help	\N
16926	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	6	feasible	\N
16927	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	6	feasible	\N
16928	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	6	feasible	\N
16929	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	6	help	\N
16930	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	6	feasible	\N
16931	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	6	help	\N
16932	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	6	feasible	\N
16933	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	6	feasible	\N
16934	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	6	help	\N
16935	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	6	help	\N
16936	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	6	help	\N
16937	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	6	help	\N
16938	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	7	feasible	\N
16939	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	7	feasible	\N
16940	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	7	feasible	\N
16941	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	7	feasible	\N
16942	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	7	feasible	\N
16943	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	7	feasible	\N
16944	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	7	feasible	\N
16945	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	7	feasible	\N
16946	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	7	feasible	\N
16947	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	7	feasible	\N
16948	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	7	feasible	\N
16949	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	7	feasible	\N
16950	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	7	feasible	\N
16951	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	7	feasible	\N
16952	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	7	feasible	\N
16953	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	7	feasible	\N
16954	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	7	feasible	\N
16955	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	7	feasible	\N
16956	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	7	feasible	\N
16957	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	7	feasible	\N
16958	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	7	feasible	\N
16959	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	7	feasible	\N
16960	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	7	feasible	\N
16961	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	7	feasible	\N
16962	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	7	feasible	\N
16963	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	7	feasible	\N
16964	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	7	feasible	\N
16965	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	7	feasible	\N
16966	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	7	feasible	\N
16967	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	7	feasible	\N
16968	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	7	feasible	\N
16969	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	7	feasible	\N
16970	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	7	feasible	\N
16971	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	7	feasible	\N
16972	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	7	feasible	\N
16973	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	7	feasible	\N
16974	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	7	feasible	\N
16975	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	7	feasible	\N
16976	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	7	feasible	\N
16977	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	7	feasible	\N
16978	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	7	feasible	\N
16979	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	7	feasible	\N
16980	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	7	feasible	\N
16981	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	7	feasible	\N
16982	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	7	feasible	\N
16983	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	7	feasible	\N
16984	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	7	feasible	\N
16985	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	7	feasible	\N
16986	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	7	feasible	\N
16987	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	7	feasible	\N
16988	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	7	feasible	\N
16989	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	7	feasible	\N
16990	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	7	feasible	\N
16991	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	7	feasible	\N
16992	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	7	feasible	\N
16993	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	7	feasible	\N
16994	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	7	feasible	\N
16995	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	7	feasible	\N
16996	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	7	feasible	\N
16997	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	7	feasible	\N
16998	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	7	feasible	\N
16999	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	7	feasible	\N
17000	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	7	feasible	\N
17001	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	7	feasible	\N
17002	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	7	feasible	\N
17003	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	7	feasible	\N
17004	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	7	feasible	\N
17005	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	7	feasible	\N
17006	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	7	feasible	\N
17007	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	7	feasible	\N
17008	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	7	feasible	\N
17009	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	7	feasible	\N
17010	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	7	feasible	\N
17011	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	7	feasible	\N
17012	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	7	feasible	\N
17013	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	7	feasible	\N
17014	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	7	feasible	\N
17015	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	7	feasible	\N
17016	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	7	feasible	\N
17017	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	7	feasible	\N
17018	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	7	feasible	\N
17019	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	7	feasible	\N
17020	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	7	feasible	\N
17021	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	8	feasible	\N
17022	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	8	feasible	\N
17023	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	8	feasible	\N
17024	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	8	feasible	\N
17025	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	8	feasible	\N
17026	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	8	feasible	\N
17027	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	8	feasible	\N
17028	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	8	feasible	\N
17029	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	8	feasible	\N
17030	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	8	feasible	\N
17031	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	8	feasible	\N
17032	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	8	feasible	\N
17033	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	8	feasible	\N
17034	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	8	feasible	\N
17035	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	8	feasible	\N
17036	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	8	feasible	\N
17037	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	8	feasible	\N
17038	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	8	feasible	\N
17039	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	8	feasible	\N
17040	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	8	feasible	\N
17041	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	8	feasible	\N
17042	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	8	feasible	\N
17043	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	8	feasible	\N
17044	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	8	feasible	\N
17045	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	8	feasible	\N
17046	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	8	feasible	\N
17047	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	8	feasible	\N
17048	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	8	feasible	\N
17049	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	8	feasible	\N
17050	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	8	feasible	\N
17051	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	8	feasible	\N
17052	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	8	feasible	\N
17053	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	8	feasible	\N
17054	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	8	feasible	\N
17055	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	8	feasible	\N
17056	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	8	feasible	\N
17057	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	8	feasible	\N
17058	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	8	feasible	\N
17059	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	8	feasible	\N
17060	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	8	feasible	\N
17061	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	8	feasible	\N
17062	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	8	feasible	\N
17063	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	8	feasible	\N
17064	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	8	feasible	\N
17065	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	8	feasible	\N
17066	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	8	feasible	\N
17067	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	8	feasible	\N
17068	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	8	feasible	\N
17069	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	8	feasible	\N
17070	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	8	feasible	\N
17071	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	8	feasible	\N
17072	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	8	feasible	\N
17073	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	8	feasible	\N
17074	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	8	feasible	\N
17075	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	8	feasible	\N
17076	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	8	feasible	\N
17077	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	8	feasible	\N
17078	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	8	feasible	\N
17079	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	8	feasible	\N
17080	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	8	feasible	\N
17081	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	8	feasible	\N
17082	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	8	feasible	\N
17083	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	8	feasible	\N
17084	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	8	feasible	\N
17085	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	8	feasible	\N
17086	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	8	feasible	\N
17087	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	8	feasible	\N
17088	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	8	feasible	\N
17089	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	8	feasible	\N
17090	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	8	feasible	\N
17091	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	8	feasible	\N
17092	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	8	feasible	\N
17093	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	8	feasible	\N
17094	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	8	feasible	\N
17095	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	8	feasible	\N
17096	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	8	feasible	\N
17097	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	8	feasible	\N
17098	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	8	feasible	\N
17099	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	8	feasible	\N
17100	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	8	feasible	\N
17101	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	8	feasible	\N
17102	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	8	feasible	\N
17103	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	8	feasible	\N
17104	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	9	feasible	\N
17105	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	9	feasible	\N
17106	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	9	feasible	\N
17107	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	9	feasible	\N
17108	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	9	feasible	\N
17109	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	9	feasible	\N
17110	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	9	feasible	\N
17111	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	9	feasible	\N
17112	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	9	feasible	\N
17113	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	9	feasible	\N
17114	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	9	feasible	\N
17115	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	9	feasible	\N
17116	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	9	feasible	\N
17117	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	9	feasible	\N
17118	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	9	feasible	\N
17119	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	9	feasible	\N
17120	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	9	feasible	\N
17121	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	9	feasible	\N
17122	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	9	feasible	\N
17123	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	9	feasible	\N
17124	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	9	feasible	\N
17125	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	9	feasible	\N
17126	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	9	feasible	\N
17127	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	9	feasible	\N
17128	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	9	feasible	\N
17129	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	9	feasible	\N
17130	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	9	feasible	\N
17131	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	9	feasible	\N
17132	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	9	feasible	\N
17133	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	9	feasible	\N
17134	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	9	feasible	\N
17135	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	9	feasible	\N
17136	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	9	feasible	\N
17137	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	9	feasible	\N
17138	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	9	feasible	\N
17139	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	9	feasible	\N
17140	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	9	feasible	\N
17141	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	9	feasible	\N
17142	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	9	feasible	\N
17143	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	9	feasible	\N
17144	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	9	feasible	\N
17145	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	9	feasible	\N
17146	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	9	feasible	\N
17147	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	9	feasible	\N
17148	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	9	feasible	\N
17149	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	9	feasible	\N
17150	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	9	feasible	\N
17151	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	9	feasible	\N
17152	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	9	feasible	\N
17153	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	9	feasible	\N
17154	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	9	feasible	\N
17155	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	9	feasible	\N
17156	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	9	feasible	\N
17157	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	9	feasible	\N
17158	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	9	feasible	\N
17159	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	9	feasible	\N
17160	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	9	feasible	\N
17161	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	9	feasible	\N
17162	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	9	feasible	\N
17163	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	9	feasible	\N
17164	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	9	feasible	\N
17165	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	9	feasible	\N
17166	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	9	feasible	\N
17167	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	9	feasible	\N
17168	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	9	feasible	\N
17169	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	9	feasible	\N
17170	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	9	feasible	\N
17171	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	9	feasible	\N
17172	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	9	feasible	\N
17173	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	9	feasible	\N
17174	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	9	feasible	\N
17175	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	9	feasible	\N
17176	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	9	feasible	\N
17177	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	9	feasible	\N
17178	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	9	feasible	\N
17179	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	9	feasible	\N
17180	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	9	feasible	\N
17181	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	9	feasible	\N
17182	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	9	feasible	\N
17183	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	9	feasible	\N
17184	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	9	feasible	\N
17185	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	9	feasible	\N
17186	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	9	feasible	\N
17187	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	10	feasible	\N
17188	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	10	feasible	\N
17189	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	10	feasible	\N
17190	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	10	feasible	\N
17191	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	10	feasible	\N
17192	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	10	feasible	\N
17193	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	10	feasible	\N
17194	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	10	feasible	\N
17195	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	10	feasible	\N
17196	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	10	feasible	\N
17197	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	10	feasible	\N
17198	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	10	feasible	\N
17199	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	10	feasible	\N
17200	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	10	feasible	\N
17201	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	10	feasible	\N
17202	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	10	feasible	\N
17203	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	10	feasible	\N
17204	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	10	feasible	\N
17205	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	10	feasible	\N
17206	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	10	feasible	\N
17207	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	10	feasible	\N
17208	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	10	feasible	\N
17209	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	10	feasible	\N
17210	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	10	feasible	\N
17211	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	10	feasible	\N
17212	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	10	feasible	\N
17213	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	10	feasible	\N
17214	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	10	feasible	\N
17215	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	10	feasible	\N
17216	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	10	feasible	\N
17217	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	10	feasible	\N
17218	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	10	feasible	\N
17219	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	10	feasible	\N
17220	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	10	feasible	\N
17221	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	10	feasible	\N
17222	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	10	feasible	\N
17223	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	10	feasible	\N
17224	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	10	feasible	\N
17225	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	10	feasible	\N
17226	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	10	feasible	\N
17227	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	10	feasible	\N
17228	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	10	feasible	\N
17229	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	10	feasible	\N
17230	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	10	feasible	\N
17231	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	10	feasible	\N
17232	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	10	feasible	\N
17233	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	10	feasible	\N
17234	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	10	feasible	\N
17235	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	10	feasible	\N
17236	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	10	feasible	\N
17237	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	10	feasible	\N
17238	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	10	feasible	\N
17239	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	10	feasible	\N
17240	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	10	feasible	\N
17241	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	10	feasible	\N
17242	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	10	feasible	\N
17243	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	10	feasible	\N
17244	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	10	feasible	\N
17245	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	10	feasible	\N
17246	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	10	feasible	\N
17247	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	10	feasible	\N
17248	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	10	feasible	\N
17249	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	10	feasible	\N
17250	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	10	feasible	\N
17251	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	10	feasible	\N
17252	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	10	feasible	\N
17253	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	10	feasible	\N
17254	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	10	feasible	\N
17255	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	10	feasible	\N
17256	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	10	feasible	\N
17257	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	10	feasible	\N
17258	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	10	feasible	\N
17259	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	10	feasible	\N
17260	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	10	feasible	\N
17261	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	10	feasible	\N
17262	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	10	feasible	\N
17263	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	10	feasible	\N
17264	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	10	feasible	\N
17265	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	10	feasible	\N
17266	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	10	feasible	\N
17267	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	10	feasible	\N
17268	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	10	feasible	\N
17269	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	10	feasible	\N
17270	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	11	feasible	\N
17271	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	11	feasible	\N
17272	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	11	feasible	\N
17273	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	11	feasible	\N
17274	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	11	feasible	\N
17275	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	11	feasible	\N
17276	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	11	feasible	\N
17277	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	11	feasible	\N
17278	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	11	feasible	\N
17279	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	11	feasible	\N
17280	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	11	feasible	\N
17281	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	11	feasible	\N
17282	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	11	feasible	\N
17283	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	11	feasible	\N
17284	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	11	feasible	\N
17285	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	11	feasible	\N
17286	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	11	feasible	\N
17287	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	11	feasible	\N
17288	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	11	feasible	\N
17289	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	11	feasible	\N
17290	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	11	feasible	\N
17291	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	11	feasible	\N
17292	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	11	feasible	\N
17293	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	11	feasible	\N
17294	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	11	feasible	\N
17295	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	11	feasible	\N
17296	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	11	feasible	\N
17297	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	11	feasible	\N
17298	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	11	feasible	\N
17299	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	11	feasible	\N
17300	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	11	feasible	\N
17301	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	11	feasible	\N
17302	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	11	feasible	\N
17303	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	11	feasible	\N
17304	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	11	feasible	\N
17305	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	11	feasible	\N
17306	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	11	feasible	\N
17307	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	11	feasible	\N
17308	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	11	feasible	\N
17309	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	11	feasible	\N
17310	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	11	feasible	\N
17311	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	11	feasible	\N
17312	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	11	feasible	\N
17313	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	11	feasible	\N
17314	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	11	feasible	\N
17315	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	11	feasible	\N
17316	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	11	feasible	\N
17317	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	11	feasible	\N
17318	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	11	feasible	\N
17319	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	11	feasible	\N
17320	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	11	feasible	\N
17321	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	11	feasible	\N
17322	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	11	feasible	\N
17323	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	11	feasible	\N
17324	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	11	feasible	\N
17325	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	11	feasible	\N
17326	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	11	feasible	\N
17327	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	11	feasible	\N
17328	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	11	feasible	\N
17329	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	11	feasible	\N
17330	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	11	feasible	\N
17331	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	11	feasible	\N
17332	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	11	feasible	\N
17333	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	11	feasible	\N
17334	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	11	feasible	\N
17335	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	11	feasible	\N
17336	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	11	feasible	\N
17337	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	11	feasible	\N
17338	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	11	feasible	\N
17339	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	11	feasible	\N
17340	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	11	feasible	\N
17341	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	11	feasible	\N
17342	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	11	feasible	\N
17343	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	11	feasible	\N
17344	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	11	feasible	\N
17345	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	11	feasible	\N
17346	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	11	feasible	\N
17347	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	11	feasible	\N
17348	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	11	feasible	\N
17349	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	11	feasible	\N
17350	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	11	feasible	\N
17351	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	11	feasible	\N
17352	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	11	feasible	\N
17353	00000000-0000-0000-0000-000000000001	527d780f-7369-4407-a599-f86c1af5ae79	12	feasible	\N
17354	00000000-0000-0000-0000-000000000001	a767cec6-0f1d-4b36-a6ec-48e568abec27	12	feasible	\N
17355	00000000-0000-0000-0000-000000000001	4d578364-03be-4fc6-b191-36f5d3d924bc	12	feasible	\N
17356	00000000-0000-0000-0000-000000000001	d824c25e-6301-45aa-bd21-350a9d5548c7	12	feasible	\N
17357	00000000-0000-0000-0000-000000000001	f8c9da9c-31ca-4250-97ef-6ed75824c7a7	12	feasible	\N
17358	00000000-0000-0000-0000-000000000001	8fb7878c-ec3a-47a7-96b1-0d6a7def0706	12	feasible	\N
17359	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	12	feasible	\N
17360	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	12	feasible	\N
17361	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	12	feasible	\N
17362	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	12	feasible	\N
17363	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	12	feasible	\N
17364	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	12	feasible	\N
17365	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	12	feasible	\N
17366	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	12	feasible	\N
17367	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	12	feasible	\N
17368	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	12	feasible	\N
17369	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	12	feasible	\N
17370	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	12	feasible	\N
17371	00000000-0000-0000-0000-000000000001	6a39906c-e310-4f2b-bb5c-bd88abea4db9	12	feasible	\N
17372	00000000-0000-0000-0000-000000000001	f340c193-ae07-4bd7-a774-c31d71840b88	12	feasible	\N
17373	00000000-0000-0000-0000-000000000001	faa22f26-4492-47fa-8a8f-c5f3de59e3b7	12	feasible	\N
17374	00000000-0000-0000-0000-000000000001	00a9a928-1777-42cb-a86f-946635181259	12	feasible	\N
17375	00000000-0000-0000-0000-000000000001	ceb01af5-6c59-4095-95f5-ca777caa31ce	12	feasible	\N
17376	00000000-0000-0000-0000-000000000001	c21471cc-a57d-4252-b788-ad5689d8b108	12	feasible	\N
17377	00000000-0000-0000-0000-000000000001	1e587e68-f9ec-49c9-b4a5-b231895b7b85	12	feasible	\N
17378	00000000-0000-0000-0000-000000000001	bb24037f-24a3-4a17-9d51-0cfb5d353a93	12	feasible	\N
17379	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	12	feasible	\N
17380	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	12	feasible	\N
17381	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	12	feasible	\N
17382	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	12	feasible	\N
17383	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	12	feasible	\N
17384	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	12	feasible	\N
17385	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	12	feasible	\N
17386	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	12	feasible	\N
17387	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	12	feasible	\N
17388	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	12	feasible	\N
17389	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	12	feasible	\N
17390	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	12	feasible	\N
17391	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	12	feasible	\N
17392	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	12	feasible	\N
17393	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	12	feasible	\N
17394	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	12	feasible	\N
17395	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	12	feasible	\N
17396	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	12	feasible	\N
17397	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	12	feasible	\N
17398	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	12	feasible	\N
17399	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	12	feasible	\N
17400	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	12	feasible	\N
17401	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	12	feasible	\N
17402	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	12	feasible	\N
17403	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	12	feasible	\N
17404	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	12	feasible	\N
17405	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	12	feasible	\N
17406	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	12	feasible	\N
17407	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	12	feasible	\N
17408	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	12	feasible	\N
17409	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	12	feasible	\N
17410	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	12	help	\N
17411	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	12	feasible	\N
17412	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	12	feasible	\N
17413	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	12	feasible	\N
17414	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	12	feasible	\N
17415	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	12	feasible	\N
17416	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	12	feasible	\N
17417	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	12	feasible	\N
17418	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	12	feasible	\N
17419	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	12	feasible	\N
17420	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	12	feasible	\N
17421	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	12	feasible	\N
17422	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	12	feasible	\N
17423	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	12	feasible	\N
17424	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	12	feasible	\N
17425	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	12	feasible	\N
17426	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	12	feasible	\N
17427	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	12	feasible	\N
17428	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	12	feasible	\N
17429	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	12	feasible	\N
17430	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	12	feasible	\N
17431	00000000-0000-0000-0000-000000000001	33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	12	feasible	\N
17432	00000000-0000-0000-0000-000000000001	311dfa95-b9a0-4b00-86c2-b64de1c0e847	12	feasible	\N
17433	00000000-0000-0000-0000-000000000001	40e5f663-dac3-4e46-8f98-9495770ae843	12	feasible	\N
17434	00000000-0000-0000-0000-000000000001	ee93e375-f631-4479-a1d7-0ce564cd41ca	12	feasible	\N
17435	00000000-0000-0000-0000-000000000001	37e51d3f-f00e-46ad-b621-0a4c372067eb	12	help	\N
17436	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	13	feasible	\N
17437	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	13	feasible	\N
17438	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	13	feasible	\N
17439	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	13	feasible	\N
17440	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	13	feasible	\N
17441	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	13	feasible	\N
17442	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	13	feasible	\N
17443	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	13	feasible	\N
17444	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	13	feasible	\N
17445	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	13	feasible	\N
17446	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	13	feasible	\N
17447	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	13	feasible	\N
17448	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	13	help	\N
17449	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	13	feasible	\N
17450	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	13	feasible	\N
17451	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	13	feasible	\N
17452	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	13	feasible	\N
17453	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	13	feasible	\N
17454	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	13	feasible	\N
17455	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	13	feasible	\N
17456	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	13	feasible	\N
17457	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	13	feasible	\N
17458	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	13	feasible	\N
17459	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	13	feasible	\N
17460	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	13	feasible	\N
17461	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	13	feasible	\N
17462	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	13	feasible	\N
17463	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	13	feasible	\N
17464	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	13	feasible	\N
17465	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	13	feasible	\N
17466	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	13	feasible	\N
17467	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	13	feasible	\N
17468	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	13	feasible	\N
17469	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	13	feasible	\N
17470	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	13	feasible	\N
17471	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	13	feasible	\N
17472	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	13	feasible	\N
17473	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	13	feasible	\N
17474	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	13	feasible	\N
17475	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	13	feasible	\N
17476	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	13	feasible	\N
17477	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	13	feasible	\N
17478	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	13	feasible	\N
17479	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	13	feasible	\N
17480	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	13	feasible	\N
17481	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	13	feasible	\N
17482	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	13	help	\N
17483	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	13	feasible	\N
17484	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	13	feasible	\N
17485	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	13	feasible	\N
17486	00000000-0000-0000-0000-000000000001	6a9326cd-7045-43ce-8510-c2593df9b46f	13	help	\N
17487	00000000-0000-0000-0000-000000000001	fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	13	feasible	\N
17488	00000000-0000-0000-0000-000000000001	3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	13	feasible	\N
17489	00000000-0000-0000-0000-000000000001	a6ba718b-23c9-499c-9557-f0c31498c1b4	13	feasible	\N
17490	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	13	help	\N
17491	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	13	feasible	\N
17492	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	13	feasible	\N
17493	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	13	feasible	\N
17494	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	13	feasible	\N
17495	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	13	feasible	\N
17496	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	13	feasible	\N
17497	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	13	feasible	\N
17498	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	13	feasible	\N
17499	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	13	feasible	\N
17500	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	13	feasible	\N
17501	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	13	feasible	\N
17502	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	13	feasible	\N
17503	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	13	feasible	\N
17504	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	13	feasible	\N
17505	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	13	feasible	\N
17506	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	13	feasible	\N
17507	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	13	feasible	\N
17508	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	13	feasible	\N
17509	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	13	feasible	\N
17510	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	13	feasible	\N
17511	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	13	feasible	\N
17512	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	13	feasible	\N
17513	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	13	help	\N
17514	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	13	help	\N
17515	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	13	help	\N
17516	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	13	help	\N
17517	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	14	feasible	\N
17518	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	14	feasible	\N
17519	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	14	feasible	\N
17520	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	14	feasible	\N
17521	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	14	feasible	\N
17522	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	14	feasible	\N
17523	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	14	feasible	\N
17524	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	14	feasible	\N
17525	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	14	feasible	\N
17526	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	14	feasible	\N
17527	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	14	feasible	\N
17528	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	14	feasible	\N
17529	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	14	feasible	\N
17530	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	14	feasible	\N
17531	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	14	feasible	\N
17532	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	14	feasible	\N
17533	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	14	feasible	\N
17534	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	14	feasible	\N
17535	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	14	feasible	\N
17536	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	14	feasible	\N
17537	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	14	feasible	\N
17538	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	14	feasible	\N
17539	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	14	feasible	\N
17540	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	14	feasible	\N
17541	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	14	feasible	\N
17542	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	14	feasible	\N
17543	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	14	feasible	\N
17544	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	14	feasible	\N
17545	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	14	feasible	\N
17546	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	14	feasible	\N
17547	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	14	feasible	\N
17548	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	14	feasible	\N
17549	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	14	feasible	\N
17550	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	14	feasible	\N
17551	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	14	help	\N
17552	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	14	feasible	\N
17553	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	14	feasible	\N
17554	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	14	feasible	\N
17555	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	14	feasible	\N
17556	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	14	feasible	\N
17557	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	14	feasible	\N
17558	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	14	feasible	\N
17559	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	14	feasible	\N
17560	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	14	feasible	\N
17561	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	14	feasible	\N
17562	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	14	feasible	\N
17563	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	14	help	\N
17564	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	14	feasible	\N
17565	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	14	feasible	\N
17566	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	14	feasible	\N
17567	00000000-0000-0000-0000-000000000001	e14ed955-88e8-4a43-86ce-21826c3fcfb7	14	feasible	\N
17568	00000000-0000-0000-0000-000000000001	2b42a1e4-5ce3-4d7b-8cb5-08937ec1514d	14	feasible	\N
17569	00000000-0000-0000-0000-000000000001	5be59b67-577f-4764-9695-e46641e85fbf	14	feasible	\N
17570	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	14	help	\N
17571	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	14	feasible	\N
17572	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	14	feasible	\N
17573	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	14	feasible	\N
17574	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	14	feasible	\N
17575	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	14	feasible	\N
17576	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	14	feasible	\N
17577	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	14	feasible	\N
17578	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	14	feasible	\N
17579	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	14	feasible	\N
17580	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	14	feasible	\N
17581	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	14	feasible	\N
17582	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	14	feasible	\N
17583	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	14	feasible	\N
17584	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	14	feasible	\N
17585	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	14	feasible	\N
17586	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	14	feasible	\N
17587	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	14	feasible	\N
17588	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	14	feasible	\N
17589	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	14	feasible	\N
17590	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	14	feasible	\N
17591	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	14	feasible	\N
17592	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	14	feasible	\N
17593	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	14	help	\N
17594	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	14	help	\N
17595	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	14	help	\N
17596	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	14	help	\N
17597	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	15	feasible	\N
17598	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	15	feasible	\N
17599	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	15	feasible	\N
17600	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	15	feasible	\N
17601	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	15	feasible	\N
17602	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	15	feasible	\N
17603	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	15	feasible	\N
17604	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	15	feasible	\N
17605	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	15	feasible	\N
17606	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	15	feasible	\N
17607	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	15	feasible	\N
17608	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	15	feasible	\N
17609	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	15	feasible	\N
17610	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	15	feasible	\N
17611	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	15	feasible	\N
17612	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	15	feasible	\N
17613	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	15	feasible	\N
17614	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	15	feasible	\N
17615	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	15	feasible	\N
17616	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	15	feasible	\N
17617	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	15	feasible	\N
17618	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	15	feasible	\N
17619	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	15	feasible	\N
17620	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	15	feasible	\N
17621	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	15	feasible	\N
17622	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	15	feasible	\N
17623	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	15	feasible	\N
17624	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	15	feasible	\N
17625	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	15	feasible	\N
17626	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	15	feasible	\N
17627	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	15	feasible	\N
17628	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	15	feasible	\N
17629	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	15	feasible	\N
17630	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	15	feasible	\N
17631	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	15	help	\N
17632	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	15	feasible	\N
17633	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	15	feasible	\N
17634	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	15	feasible	\N
17635	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	15	feasible	\N
17636	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	15	feasible	\N
17637	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	15	feasible	\N
17638	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	15	feasible	\N
17639	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	15	feasible	\N
17640	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	15	feasible	\N
17641	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	15	feasible	\N
17642	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	15	feasible	\N
17643	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	15	help	\N
17644	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	15	feasible	\N
17645	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	15	feasible	\N
17646	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	15	feasible	\N
17647	00000000-0000-0000-0000-000000000001	e14ed955-88e8-4a43-86ce-21826c3fcfb7	15	feasible	\N
17648	00000000-0000-0000-0000-000000000001	2b42a1e4-5ce3-4d7b-8cb5-08937ec1514d	15	feasible	\N
17649	00000000-0000-0000-0000-000000000001	5be59b67-577f-4764-9695-e46641e85fbf	15	feasible	\N
17650	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	15	help	\N
17651	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	15	feasible	\N
17652	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	15	feasible	\N
17653	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	15	feasible	\N
17654	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	15	feasible	\N
17655	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	15	feasible	\N
17656	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	15	feasible	\N
17657	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	15	feasible	\N
17658	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	15	feasible	\N
17659	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	15	feasible	\N
17660	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	15	feasible	\N
17661	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	15	feasible	\N
17662	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	15	feasible	\N
17663	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	15	feasible	\N
17664	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	15	feasible	\N
17665	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	15	feasible	\N
17666	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	15	feasible	\N
17667	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	15	feasible	\N
17668	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	15	feasible	\N
17669	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	15	feasible	\N
17670	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	15	feasible	\N
17671	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	15	feasible	\N
17672	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	15	feasible	\N
17673	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	15	help	\N
17674	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	15	help	\N
17675	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	15	help	\N
17676	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	15	help	\N
17677	00000000-0000-0000-0000-000000000001	db1e7475-a1e6-4c6c-9892-84da11a65e13	16	feasible	\N
17678	00000000-0000-0000-0000-000000000001	85f37baa-20b6-44f4-8b81-0bac91f2e26c	16	feasible	\N
17679	00000000-0000-0000-0000-000000000001	ca537841-6ca3-4f80-8649-d9ff37a4f3e7	16	feasible	\N
17680	00000000-0000-0000-0000-000000000001	166bd53d-51e8-456e-9ae8-0ba16bb00fed	16	feasible	\N
17681	00000000-0000-0000-0000-000000000001	96301603-727e-4448-9e31-72846d1dd030	16	feasible	\N
17682	00000000-0000-0000-0000-000000000001	90d2b53d-8e02-4fd3-8499-6c04e1fcd381	16	feasible	\N
17683	00000000-0000-0000-0000-000000000001	71cc6177-702c-470d-aca7-83e99d453eef	16	feasible	\N
17684	00000000-0000-0000-0000-000000000001	041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	16	feasible	\N
17685	00000000-0000-0000-0000-000000000001	90f5d942-5169-48cd-8529-95481b73bd25	16	feasible	\N
17686	00000000-0000-0000-0000-000000000001	2dd46659-6392-46a4-a119-515c2b50c813	16	feasible	\N
17687	00000000-0000-0000-0000-000000000001	ef8f0059-072a-4dc4-8a44-0c9cec6737cd	16	feasible	\N
17688	00000000-0000-0000-0000-000000000001	bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	16	feasible	\N
17689	00000000-0000-0000-0000-000000000001	dc752f45-0d09-49c1-ade3-e9ac077d3e01	16	feasible	\N
17690	00000000-0000-0000-0000-000000000001	8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	16	feasible	\N
17691	00000000-0000-0000-0000-000000000001	b224191f-11d1-4a8b-963c-0efa96706602	16	feasible	\N
17692	00000000-0000-0000-0000-000000000001	0b8bc379-36f7-417f-84a8-80697af161e5	16	feasible	\N
17693	00000000-0000-0000-0000-000000000001	479ea398-f09d-4f23-888b-a8222ffac900	16	feasible	\N
17694	00000000-0000-0000-0000-000000000001	c9ece822-bcb8-4c31-8a8f-99aafb106b05	16	feasible	\N
17695	00000000-0000-0000-0000-000000000001	e3e47579-e91b-4519-88bc-a056fca12960	16	feasible	\N
17696	00000000-0000-0000-0000-000000000001	329c7cdc-5251-4721-9566-b8359f73e73c	16	feasible	\N
17697	00000000-0000-0000-0000-000000000001	52296537-a3ea-4c8c-ab57-85a921b9ca24	16	feasible	\N
17698	00000000-0000-0000-0000-000000000001	c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	16	feasible	\N
17699	00000000-0000-0000-0000-000000000001	a1c8b3ce-235d-48a8-8e94-391ae4d73333	16	feasible	\N
17700	00000000-0000-0000-0000-000000000001	ad879e5b-9604-4ee1-a918-39a5948c1ebc	16	feasible	\N
17701	00000000-0000-0000-0000-000000000001	34015533-dac2-4758-b8b8-7b6e7226aeb3	16	feasible	\N
17702	00000000-0000-0000-0000-000000000001	650b6730-b952-42b1-a8ba-0afeab2fc4ea	16	feasible	\N
17703	00000000-0000-0000-0000-000000000001	b7df5eb2-b575-4812-a285-973db10c0d4d	16	feasible	\N
17704	00000000-0000-0000-0000-000000000001	bdf493c2-62d9-476b-8a2a-384184843f8b	16	feasible	\N
17705	00000000-0000-0000-0000-000000000001	3a13367c-1116-4e5c-9065-9b23d0550546	16	feasible	\N
17706	00000000-0000-0000-0000-000000000001	6f9a8461-932e-4b10-9516-afc8213e8fc7	16	feasible	\N
17707	00000000-0000-0000-0000-000000000001	ab3f69a6-5778-4147-84d3-87e75b93c9fb	16	feasible	\N
17708	00000000-0000-0000-0000-000000000001	a70b7cfc-41ab-4016-bd19-62f875107f48	16	feasible	\N
17709	00000000-0000-0000-0000-000000000001	ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	16	feasible	\N
17710	00000000-0000-0000-0000-000000000001	7f586bdc-9cc3-4388-b5bd-31e59b33019a	16	feasible	\N
17711	00000000-0000-0000-0000-000000000001	2d66ea68-0ee0-4901-820f-f10ef56d6961	16	help	\N
17712	00000000-0000-0000-0000-000000000001	f451d903-2e24-46a8-a0d4-10f0ff2a443f	16	feasible	\N
17713	00000000-0000-0000-0000-000000000001	2b6b4f66-1906-42bc-9578-1bcd388c0bef	16	feasible	\N
17714	00000000-0000-0000-0000-000000000001	300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	16	feasible	\N
17715	00000000-0000-0000-0000-000000000001	34f74e69-7f22-4570-9708-5250067b05a3	16	feasible	\N
17716	00000000-0000-0000-0000-000000000001	1840f7c3-a632-490c-9b7e-55464494e547	16	feasible	\N
17717	00000000-0000-0000-0000-000000000001	e4dffc1b-3f32-4ec7-a89c-06ff086957eb	16	feasible	\N
17718	00000000-0000-0000-0000-000000000001	9aaaec92-435b-428d-9337-045b0227b8e4	16	feasible	\N
17719	00000000-0000-0000-0000-000000000001	125d5605-3a61-4a8a-b748-4ea8d7edf22b	16	feasible	\N
17720	00000000-0000-0000-0000-000000000001	1bb5673f-5db1-4269-8523-1e8c4eb8923a	16	feasible	\N
17721	00000000-0000-0000-0000-000000000001	5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	16	feasible	\N
17722	00000000-0000-0000-0000-000000000001	e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	16	feasible	\N
17723	00000000-0000-0000-0000-000000000001	0557a635-8836-4012-b0dd-bc2373a7e2cc	16	help	\N
17724	00000000-0000-0000-0000-000000000001	e803ce31-66bb-4579-8f28-a6dc85e3e6da	16	feasible	\N
17725	00000000-0000-0000-0000-000000000001	d6ae40bd-5319-4b29-9588-ed9369ed7420	16	feasible	\N
17726	00000000-0000-0000-0000-000000000001	0d59f45a-bbf1-4dd0-8069-6aacd41fc045	16	feasible	\N
17727	00000000-0000-0000-0000-000000000001	e14ed955-88e8-4a43-86ce-21826c3fcfb7	16	feasible	\N
17728	00000000-0000-0000-0000-000000000001	2b42a1e4-5ce3-4d7b-8cb5-08937ec1514d	16	feasible	\N
17729	00000000-0000-0000-0000-000000000001	5be59b67-577f-4764-9695-e46641e85fbf	16	feasible	\N
17730	00000000-0000-0000-0000-000000000001	6a860717-662a-4cb3-bdfa-f8e8153cf754	16	help	\N
17731	00000000-0000-0000-0000-000000000001	27ea0a14-0028-49c8-8848-16be577284a0	16	feasible	\N
17732	00000000-0000-0000-0000-000000000001	06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	16	feasible	\N
17733	00000000-0000-0000-0000-000000000001	dcf60a74-ad02-4788-bf7d-509c702afe2b	16	feasible	\N
17734	00000000-0000-0000-0000-000000000001	eb7a2b47-adff-4fb1-a198-449d364b3e4a	16	feasible	\N
17735	00000000-0000-0000-0000-000000000001	b5890670-17c1-4ae7-b878-9bc59e12103e	16	feasible	\N
17736	00000000-0000-0000-0000-000000000001	ad52ebca-fafe-4118-965d-b1c294e06b78	16	feasible	\N
17737	00000000-0000-0000-0000-000000000001	0891e5f5-a2ee-4b4a-9727-98bb107b2088	16	feasible	\N
17738	00000000-0000-0000-0000-000000000001	367cc25c-50cd-4f82-940b-cec18d3c6cf0	16	feasible	\N
17739	00000000-0000-0000-0000-000000000001	5b663a9d-a971-461c-86ab-73e2f950428c	16	feasible	\N
17740	00000000-0000-0000-0000-000000000001	5a90ee4a-313f-4fca-b9b0-a895ee7724bc	16	feasible	\N
17741	00000000-0000-0000-0000-000000000001	f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	16	feasible	\N
17742	00000000-0000-0000-0000-000000000001	39377224-51bf-498e-8200-23382fddfb89	16	feasible	\N
17743	00000000-0000-0000-0000-000000000001	25d24616-0d8d-4581-8ed0-435edac62deb	16	feasible	\N
17744	00000000-0000-0000-0000-000000000001	e747eb93-820e-4fac-883d-725d058031e7	16	feasible	\N
17745	00000000-0000-0000-0000-000000000001	d69b56f9-7641-4b0f-bf41-a59fdbc34851	16	feasible	\N
17746	00000000-0000-0000-0000-000000000001	2d0bcd11-beec-449c-8d46-52025bfa39b3	16	feasible	\N
17747	00000000-0000-0000-0000-000000000001	a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	16	feasible	\N
17748	00000000-0000-0000-0000-000000000001	edb38b06-01df-45c0-874f-0614f1fc1033	16	feasible	\N
17749	00000000-0000-0000-0000-000000000001	89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	16	feasible	\N
17750	00000000-0000-0000-0000-000000000001	9ef0a863-d39d-4acc-a10b-eb9210593e76	16	feasible	\N
17751	00000000-0000-0000-0000-000000000001	db5a4119-a125-4a22-845f-da86fc6a6f51	16	feasible	\N
17752	00000000-0000-0000-0000-000000000001	c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	16	feasible	\N
17753	00000000-0000-0000-0000-000000000001	ffa86c98-1c38-49d5-aada-732e2e7c86bc	16	help	\N
17754	00000000-0000-0000-0000-000000000001	9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	16	help	\N
17755	00000000-0000-0000-0000-000000000001	bed2d699-a4b1-4df4-ae29-fcd14acef293	16	help	\N
17756	00000000-0000-0000-0000-000000000001	10b43001-753d-4c91-81b3-67aafcf62c09	16	help	\N
17757	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	1	feasible	\N
17758	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	1	feasible	\N
17759	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	1	feasible	\N
17760	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	1	feasible	\N
17761	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	1	feasible	\N
17762	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	1	feasible	\N
17763	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	1	feasible	\N
17764	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	1	feasible	\N
17765	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	1	feasible	\N
17766	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	1	feasible	\N
17767	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	1	feasible	\N
17768	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	1	feasible	\N
17769	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	1	feasible	\N
17770	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	1	feasible	\N
17771	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	1	feasible	\N
17772	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	1	feasible	\N
17773	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	1	feasible	\N
17774	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	1	feasible	\N
17775	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	1	feasible	\N
17776	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	1	feasible	\N
17777	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	1	feasible	\N
17778	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	1	feasible	\N
17779	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	1	feasible	\N
17780	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	1	feasible	\N
17781	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	1	feasible	\N
17782	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	1	feasible	\N
17783	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	1	feasible	\N
17784	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	1	feasible	\N
17785	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	1	feasible	\N
17786	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	1	feasible	\N
17787	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	1	feasible	\N
17788	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	1	feasible	\N
17789	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	1	feasible	\N
17790	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	1	feasible	\N
17791	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	1	feasible	\N
17792	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	1	feasible	\N
17793	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	1	feasible	\N
17794	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	1	feasible	\N
17795	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	1	feasible	\N
17796	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	1	feasible	\N
17797	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	1	feasible	\N
17798	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	1	feasible	\N
17799	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	1	feasible	\N
17800	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	1	feasible	\N
17801	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	1	feasible	\N
17802	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	1	feasible	\N
17803	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	1	feasible	\N
17804	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	1	feasible	\N
17805	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	1	feasible	\N
17806	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	1	feasible	\N
17807	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	1	feasible	\N
17808	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	1	feasible	\N
17809	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	1	feasible	\N
17810	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	1	feasible	\N
17811	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	1	feasible	\N
17812	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	1	feasible	\N
17813	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	1	feasible	\N
17814	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	1	feasible	\N
17815	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	1	feasible	\N
17816	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	1	feasible	\N
17817	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	1	feasible	\N
17818	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	1	feasible	\N
17819	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	1	feasible	\N
17820	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	1	feasible	\N
17821	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	1	feasible	\N
17822	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	1	feasible	\N
17823	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	1	feasible	\N
17824	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	1	feasible	\N
17825	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	1	feasible	\N
17826	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	1	feasible	\N
17827	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	1	feasible	\N
17828	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	1	feasible	\N
17829	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	1	feasible	\N
17830	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	1	feasible	\N
17831	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	1	feasible	\N
17832	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	1	feasible	\N
17833	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	1	feasible	\N
17834	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	1	feasible	\N
17835	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	1	feasible	\N
17836	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	1	feasible	\N
17837	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	1	feasible	\N
17838	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	1	feasible	\N
17839	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	1	feasible	\N
17840	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	1	feasible	\N
17841	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	1	feasible	\N
17842	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	1	feasible	\N
17843	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	2	feasible	\N
17844	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	2	feasible	\N
17845	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	2	feasible	\N
17846	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	2	feasible	\N
17847	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	2	feasible	\N
17848	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	2	feasible	\N
17849	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	2	feasible	\N
17850	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	2	feasible	\N
17851	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	2	feasible	\N
17852	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	2	feasible	\N
17853	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	2	feasible	\N
17854	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	2	feasible	\N
17855	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	2	feasible	\N
17856	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	2	feasible	\N
17857	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	2	feasible	\N
17858	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	2	feasible	\N
17859	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	2	feasible	\N
17860	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	2	feasible	\N
17861	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	2	feasible	\N
17862	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	2	feasible	\N
17863	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	2	feasible	\N
17864	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	2	feasible	\N
17865	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	2	feasible	\N
17866	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	2	feasible	\N
17867	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	2	feasible	\N
17868	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	2	feasible	\N
17869	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	2	feasible	\N
17870	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	2	feasible	\N
17871	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	2	feasible	\N
17872	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	2	feasible	\N
17873	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	2	feasible	\N
17874	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	2	feasible	\N
17875	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	2	feasible	\N
17876	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	2	feasible	\N
17877	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	2	feasible	\N
17878	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	2	feasible	\N
17879	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	2	feasible	\N
17880	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	2	feasible	\N
17881	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	2	feasible	\N
17882	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	2	feasible	\N
17883	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	2	feasible	\N
17884	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	2	feasible	\N
17885	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	2	feasible	\N
17886	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	2	feasible	\N
17887	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	2	feasible	\N
17888	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	2	feasible	\N
17889	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	2	feasible	\N
17890	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	2	feasible	\N
17891	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	2	feasible	\N
17892	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	2	feasible	\N
17893	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	2	feasible	\N
17894	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	2	feasible	\N
17895	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	2	feasible	\N
17896	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	2	feasible	\N
17897	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	2	feasible	\N
17898	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	2	feasible	\N
17899	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	2	feasible	\N
17900	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	2	feasible	\N
17901	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	2	feasible	\N
17902	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	2	feasible	\N
17903	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	2	feasible	\N
17904	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	2	feasible	\N
17905	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	2	feasible	\N
17906	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	2	feasible	\N
17907	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	2	feasible	\N
17908	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	2	feasible	\N
17909	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	2	feasible	\N
17910	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	2	feasible	\N
17911	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	2	feasible	\N
17912	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	2	feasible	\N
17913	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	2	feasible	\N
17914	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	2	feasible	\N
17915	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	2	feasible	\N
17916	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	2	feasible	\N
17917	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	2	feasible	\N
17918	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	2	feasible	\N
17919	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	2	feasible	\N
17920	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	2	feasible	\N
17921	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	2	feasible	\N
17922	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	2	feasible	\N
17923	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	2	feasible	\N
17924	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	2	feasible	\N
17925	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	2	feasible	\N
17926	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	2	feasible	\N
17927	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	2	feasible	\N
17928	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	2	feasible	\N
17929	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	3	feasible	\N
17930	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	3	feasible	\N
17931	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	3	feasible	\N
17932	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	3	feasible	\N
17933	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	3	feasible	\N
17934	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	3	feasible	\N
17935	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	3	feasible	\N
17936	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	3	feasible	\N
17937	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	3	feasible	\N
17938	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	3	feasible	\N
17939	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	3	feasible	\N
17940	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	3	feasible	\N
17941	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	3	feasible	\N
17942	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	3	feasible	\N
17943	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	3	feasible	\N
17944	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	3	feasible	\N
17945	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	3	feasible	\N
17946	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	3	feasible	\N
17947	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	3	feasible	\N
17948	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	3	feasible	\N
17949	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	3	feasible	\N
17950	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	3	feasible	\N
17951	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	3	feasible	\N
17952	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	3	feasible	\N
17953	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	3	feasible	\N
17954	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	3	feasible	\N
17955	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	3	feasible	\N
17956	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	3	feasible	\N
17957	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	3	feasible	\N
17958	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	3	feasible	\N
17959	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	3	feasible	\N
17960	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	3	help	\N
17961	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	3	help	\N
17962	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	3	feasible	\N
17963	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	3	feasible	\N
17964	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	3	help	\N
17965	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	3	help	\N
17966	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	3	feasible	\N
17967	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	3	feasible	\N
17968	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	3	feasible	\N
17969	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	3	help	\N
17970	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	3	feasible	\N
17971	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	3	feasible	\N
17972	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	3	feasible	\N
17973	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	3	help	\N
17974	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	3	feasible	\N
17975	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	3	feasible	\N
17976	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	3	help	\N
17977	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	3	feasible	\N
17978	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	3	feasible	\N
17979	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	3	feasible	\N
17980	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	3	feasible	\N
17981	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	3	feasible	\N
17982	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	3	feasible	\N
17983	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	3	feasible	\N
17984	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	3	feasible	\N
17985	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	3	feasible	\N
17986	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	3	feasible	\N
17987	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	3	feasible	\N
17988	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	3	feasible	\N
17989	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	3	help	\N
17990	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	3	help	\N
17991	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	3	help	\N
17992	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	3	feasible	\N
17993	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	3	feasible	\N
17994	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	3	feasible	\N
17995	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	3	help	\N
17996	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	3	feasible	\N
17997	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	3	feasible	\N
17998	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	3	feasible	\N
17999	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	3	feasible	\N
18000	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	3	feasible	\N
18001	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	3	feasible	\N
18002	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	3	feasible	\N
18003	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	3	feasible	\N
18004	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	3	feasible	\N
18005	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	3	feasible	\N
18006	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	3	feasible	\N
18007	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	3	feasible	\N
18008	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	3	feasible	\N
18009	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	3	feasible	\N
18010	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	3	feasible	\N
18011	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	3	feasible	\N
18012	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	3	feasible	\N
18013	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	3	feasible	\N
18014	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	3	feasible	\N
18015	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	4	feasible	\N
18016	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	4	feasible	\N
18017	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	4	feasible	\N
18018	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	4	feasible	\N
18019	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	4	feasible	\N
18020	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	4	help	\N
18021	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	4	feasible	\N
18022	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	4	feasible	\N
18023	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	4	feasible	\N
18024	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	4	feasible	\N
18025	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	4	feasible	\N
18026	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	4	feasible	\N
18027	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	4	help	\N
18028	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	4	feasible	\N
18029	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	4	feasible	\N
18030	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	4	feasible	\N
18031	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	4	help	\N
18032	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	4	help	\N
18033	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	4	help	\N
18034	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	4	feasible	\N
18035	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	4	feasible	\N
18036	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	4	help	\N
18037	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	4	feasible	\N
18038	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	4	feasible	\N
18039	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	4	feasible	\N
18040	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	4	feasible	\N
18041	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	4	help	\N
18042	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	4	help	\N
18043	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	4	feasible	\N
18044	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	4	feasible	\N
18045	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	4	feasible	\N
18046	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	4	help	\N
18047	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	4	help	\N
18048	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	4	feasible	\N
18049	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	4	feasible	\N
18050	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	4	avoid	\N
18051	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	4	avoid	\N
18052	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	4	feasible	\N
18053	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	4	feasible	\N
18054	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	4	feasible	\N
18055	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	4	help	\N
18056	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	4	feasible	\N
18057	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	4	feasible	\N
18058	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	4	feasible	\N
18059	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	4	help	\N
18060	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	4	help	\N
18061	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	4	feasible	\N
18062	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	4	help	\N
18063	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	4	help	\N
18064	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	4	help	\N
18065	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	4	feasible	\N
18066	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	4	feasible	\N
18067	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	4	feasible	\N
18068	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	4	feasible	\N
18069	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	4	feasible	\N
18070	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	4	help	\N
18071	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	4	feasible	\N
18072	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	4	feasible	\N
18073	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	4	feasible	\N
18074	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	4	feasible	\N
18075	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	4	help	\N
18076	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	4	help	\N
18077	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	4	help	\N
18078	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	4	feasible	\N
18079	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	4	help	\N
18080	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	4	help	\N
18081	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	4	help	\N
18082	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	4	help	\N
18083	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	4	feasible	\N
18084	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	4	help	\N
18085	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	4	help	\N
18086	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	4	help	\N
18087	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	4	feasible	\N
18088	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	4	help	\N
18089	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	4	help	\N
18090	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	4	feasible	\N
18091	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	4	feasible	\N
18092	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	4	feasible	\N
18093	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	4	feasible	\N
18094	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	4	feasible	\N
18095	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	4	feasible	\N
18096	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	4	feasible	\N
18097	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	4	help	\N
18098	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	4	help	\N
18099	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	4	help	\N
18100	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	4	help	\N
18101	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	5	feasible	\N
18102	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	5	feasible	\N
18103	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	5	feasible	\N
18104	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	5	feasible	\N
18105	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	5	feasible	\N
18106	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	5	help	\N
18107	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	5	feasible	\N
18108	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	5	feasible	\N
18109	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	5	feasible	\N
18110	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	5	feasible	\N
18111	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	5	feasible	\N
18112	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	5	feasible	\N
18113	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	5	help	\N
18114	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	5	feasible	\N
18115	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	5	feasible	\N
18116	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	5	feasible	\N
18117	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	5	help	\N
18118	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	5	help	\N
18119	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	5	help	\N
18120	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	5	feasible	\N
18121	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	5	feasible	\N
18122	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	5	help	\N
18123	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	5	feasible	\N
18124	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	5	feasible	\N
18125	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	5	feasible	\N
18126	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	5	feasible	\N
18127	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	5	help	\N
18128	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	5	help	\N
18129	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	5	feasible	\N
18130	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	5	feasible	\N
18131	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	5	feasible	\N
18132	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	5	help	\N
18133	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	5	help	\N
18134	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	5	feasible	\N
18135	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	5	feasible	\N
18136	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	5	avoid	\N
18137	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	5	avoid	\N
18138	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	5	feasible	\N
18139	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	5	feasible	\N
18140	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	5	feasible	\N
18141	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	5	help	\N
18142	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	5	feasible	\N
18143	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	5	feasible	\N
18144	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	5	feasible	\N
18145	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	5	help	\N
18146	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	5	help	\N
18147	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	5	feasible	\N
18148	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	5	help	\N
18149	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	5	help	\N
18150	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	5	help	\N
18151	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	5	feasible	\N
18152	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	5	feasible	\N
18153	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	5	feasible	\N
18154	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	5	feasible	\N
18155	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	5	feasible	\N
18156	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	5	help	\N
18157	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	5	feasible	\N
18158	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	5	feasible	\N
18159	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	5	feasible	\N
18160	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	5	feasible	\N
18161	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	5	help	\N
18162	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	5	help	\N
18163	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	5	help	\N
18164	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	5	feasible	\N
18165	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	5	help	\N
18166	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	5	help	\N
18167	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	5	help	\N
18168	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	5	help	\N
18169	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	5	feasible	\N
18170	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	5	help	\N
18171	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	5	help	\N
18172	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	5	help	\N
18173	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	5	feasible	\N
18174	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	5	help	\N
18175	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	5	help	\N
18176	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	5	feasible	\N
18177	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	5	feasible	\N
18178	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	5	feasible	\N
18179	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	5	feasible	\N
18180	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	5	feasible	\N
18181	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	5	feasible	\N
18182	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	5	feasible	\N
18183	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	5	help	\N
18184	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	5	help	\N
18185	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	5	help	\N
18186	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	5	help	\N
18187	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	6	feasible	\N
18188	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	6	feasible	\N
18189	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	6	feasible	\N
18190	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	6	feasible	\N
18191	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	6	feasible	\N
18192	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	6	help	\N
18193	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	6	feasible	\N
18194	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	6	feasible	\N
18195	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	6	feasible	\N
18196	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	6	feasible	\N
18197	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	6	feasible	\N
18198	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	6	feasible	\N
18199	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	6	help	\N
18200	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	6	feasible	\N
18201	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	6	feasible	\N
18202	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	6	feasible	\N
18203	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	6	help	\N
18204	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	6	help	\N
18205	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	6	help	\N
18206	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	6	feasible	\N
18207	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	6	feasible	\N
18208	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	6	help	\N
18209	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	6	feasible	\N
18210	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	6	feasible	\N
18211	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	6	feasible	\N
18212	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	6	feasible	\N
18213	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	6	help	\N
18214	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	6	help	\N
18215	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	6	feasible	\N
18216	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	6	feasible	\N
18217	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	6	feasible	\N
18218	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	6	help	\N
18219	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	6	help	\N
18220	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	6	feasible	\N
18221	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	6	feasible	\N
18222	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	6	avoid	\N
18223	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	6	avoid	\N
18224	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	6	feasible	\N
18225	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	6	feasible	\N
18226	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	6	feasible	\N
18227	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	6	help	\N
18228	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	6	feasible	\N
18229	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	6	feasible	\N
18230	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	6	feasible	\N
18231	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	6	help	\N
18232	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	6	help	\N
18233	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	6	feasible	\N
18234	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	6	help	\N
18235	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	6	help	\N
18236	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	6	help	\N
18237	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	6	feasible	\N
18238	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	6	feasible	\N
18239	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	6	feasible	\N
18240	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	6	feasible	\N
18241	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	6	feasible	\N
18242	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	6	help	\N
18243	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	6	feasible	\N
18244	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	6	feasible	\N
18245	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	6	feasible	\N
18246	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	6	feasible	\N
18247	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	6	help	\N
18248	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	6	help	\N
18249	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	6	help	\N
18250	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	6	feasible	\N
18251	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	6	help	\N
18252	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	6	help	\N
18253	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	6	help	\N
18254	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	6	help	\N
18255	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	6	feasible	\N
18256	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	6	help	\N
18257	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	6	help	\N
18258	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	6	help	\N
18259	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	6	feasible	\N
18260	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	6	help	\N
18261	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	6	help	\N
18262	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	6	feasible	\N
18263	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	6	feasible	\N
18264	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	6	feasible	\N
18265	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	6	feasible	\N
18266	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	6	feasible	\N
18267	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	6	feasible	\N
18268	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	6	feasible	\N
18269	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	6	help	\N
18270	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	6	help	\N
18271	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	6	help	\N
18272	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	6	help	\N
18273	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	7	feasible	\N
18274	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	7	feasible	\N
18275	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	7	feasible	\N
18276	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	7	feasible	\N
18277	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	7	feasible	\N
18278	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	7	feasible	\N
18279	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	7	feasible	\N
18280	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	7	feasible	\N
18281	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	7	feasible	\N
18282	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	7	feasible	\N
18283	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	7	feasible	\N
18284	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	7	feasible	\N
18285	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	7	feasible	\N
18286	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	7	feasible	\N
18287	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	7	feasible	\N
18288	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	7	feasible	\N
18289	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	7	feasible	\N
18290	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	7	feasible	\N
18291	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	7	feasible	\N
18292	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	7	feasible	\N
18293	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	7	feasible	\N
18294	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	7	feasible	\N
18295	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	7	feasible	\N
18296	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	7	feasible	\N
18297	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	7	feasible	\N
18298	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	7	feasible	\N
18299	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	7	feasible	\N
18300	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	7	feasible	\N
18301	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	7	feasible	\N
18302	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	7	feasible	\N
18303	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	7	feasible	\N
18304	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	7	feasible	\N
18305	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	7	feasible	\N
18306	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	7	feasible	\N
18307	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	7	feasible	\N
18308	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	7	feasible	\N
18309	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	7	feasible	\N
18310	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	7	feasible	\N
18311	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	7	feasible	\N
18312	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	7	feasible	\N
18313	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	7	feasible	\N
18314	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	7	feasible	\N
18315	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	7	feasible	\N
18316	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	7	feasible	\N
18317	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	7	feasible	\N
18318	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	7	feasible	\N
18319	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	7	feasible	\N
18320	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	7	feasible	\N
18321	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	7	feasible	\N
18322	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	7	feasible	\N
18323	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	7	feasible	\N
18324	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	7	feasible	\N
18325	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	7	feasible	\N
18326	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	7	feasible	\N
18327	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	7	feasible	\N
18328	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	7	feasible	\N
18329	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	7	feasible	\N
18330	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	7	feasible	\N
18331	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	7	feasible	\N
18332	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	7	feasible	\N
18333	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	7	feasible	\N
18334	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	7	feasible	\N
18335	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	7	feasible	\N
18336	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	7	feasible	\N
18337	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	7	feasible	\N
18338	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	7	feasible	\N
18339	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	7	feasible	\N
18340	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	7	feasible	\N
18341	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	7	feasible	\N
18342	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	7	feasible	\N
18343	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	7	feasible	\N
18344	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	7	feasible	\N
18345	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	7	feasible	\N
18346	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	7	feasible	\N
18347	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	7	feasible	\N
18348	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	7	feasible	\N
18349	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	7	feasible	\N
18350	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	7	feasible	\N
18351	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	7	feasible	\N
18352	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	7	feasible	\N
18353	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	7	feasible	\N
18354	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	7	feasible	\N
18355	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	7	feasible	\N
18356	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	7	feasible	\N
18357	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	7	feasible	\N
18358	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	7	feasible	\N
18359	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	8	feasible	\N
18360	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	8	feasible	\N
18361	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	8	feasible	\N
18362	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	8	feasible	\N
18363	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	8	feasible	\N
18364	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	8	feasible	\N
18365	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	8	feasible	\N
18366	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	8	feasible	\N
18367	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	8	feasible	\N
18368	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	8	feasible	\N
18369	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	8	feasible	\N
18370	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	8	feasible	\N
18371	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	8	feasible	\N
18372	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	8	feasible	\N
18373	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	8	feasible	\N
18374	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	8	feasible	\N
18375	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	8	feasible	\N
18376	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	8	feasible	\N
18377	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	8	feasible	\N
18378	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	8	feasible	\N
18379	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	8	feasible	\N
18380	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	8	feasible	\N
18381	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	8	feasible	\N
18382	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	8	feasible	\N
18383	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	8	feasible	\N
18384	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	8	feasible	\N
18385	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	8	feasible	\N
18386	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	8	feasible	\N
18387	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	8	feasible	\N
18388	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	8	feasible	\N
18389	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	8	feasible	\N
18390	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	8	feasible	\N
18391	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	8	feasible	\N
18392	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	8	feasible	\N
18393	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	8	feasible	\N
18394	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	8	feasible	\N
18395	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	8	feasible	\N
18396	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	8	feasible	\N
18397	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	8	feasible	\N
18398	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	8	feasible	\N
18399	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	8	feasible	\N
18400	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	8	feasible	\N
18401	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	8	feasible	\N
18402	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	8	feasible	\N
18403	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	8	feasible	\N
18404	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	8	feasible	\N
18405	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	8	feasible	\N
18406	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	8	feasible	\N
18407	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	8	feasible	\N
18408	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	8	feasible	\N
18409	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	8	feasible	\N
18410	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	8	feasible	\N
18411	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	8	feasible	\N
18412	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	8	feasible	\N
18413	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	8	feasible	\N
18414	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	8	feasible	\N
18415	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	8	feasible	\N
18416	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	8	feasible	\N
18417	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	8	feasible	\N
18418	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	8	feasible	\N
18419	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	8	feasible	\N
18420	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	8	feasible	\N
18421	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	8	feasible	\N
18422	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	8	feasible	\N
18423	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	8	feasible	\N
18424	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	8	feasible	\N
18425	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	8	feasible	\N
18426	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	8	feasible	\N
18427	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	8	feasible	\N
18428	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	8	feasible	\N
18429	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	8	feasible	\N
18430	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	8	feasible	\N
18431	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	8	feasible	\N
18432	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	8	feasible	\N
18433	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	8	feasible	\N
18434	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	8	feasible	\N
18435	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	8	feasible	\N
18436	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	8	feasible	\N
18437	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	8	feasible	\N
18438	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	8	feasible	\N
18439	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	8	feasible	\N
18440	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	8	feasible	\N
18441	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	8	feasible	\N
18442	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	8	feasible	\N
18443	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	8	feasible	\N
18444	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	8	feasible	\N
18445	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	9	feasible	\N
18446	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	9	feasible	\N
18447	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	9	feasible	\N
18448	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	9	feasible	\N
18449	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	9	feasible	\N
18450	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	9	feasible	\N
18451	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	9	feasible	\N
18452	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	9	feasible	\N
18453	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	9	feasible	\N
18454	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	9	feasible	\N
18455	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	9	feasible	\N
18456	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	9	feasible	\N
18457	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	9	feasible	\N
18458	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	9	feasible	\N
18459	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	9	feasible	\N
18460	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	9	feasible	\N
18461	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	9	feasible	\N
18462	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	9	feasible	\N
18463	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	9	feasible	\N
18464	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	9	feasible	\N
18465	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	9	feasible	\N
18466	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	9	feasible	\N
18467	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	9	feasible	\N
18468	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	9	feasible	\N
18469	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	9	feasible	\N
18470	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	9	feasible	\N
18471	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	9	feasible	\N
18472	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	9	feasible	\N
18473	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	9	feasible	\N
18474	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	9	feasible	\N
18475	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	9	feasible	\N
18476	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	9	feasible	\N
18477	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	9	feasible	\N
18478	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	9	feasible	\N
18479	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	9	feasible	\N
18480	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	9	feasible	\N
18481	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	9	feasible	\N
18482	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	9	feasible	\N
18483	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	9	feasible	\N
18484	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	9	feasible	\N
18485	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	9	feasible	\N
18486	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	9	feasible	\N
18487	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	9	feasible	\N
18488	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	9	feasible	\N
18489	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	9	feasible	\N
18490	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	9	feasible	\N
18491	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	9	feasible	\N
18492	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	9	feasible	\N
18493	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	9	feasible	\N
18494	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	9	feasible	\N
18495	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	9	feasible	\N
18496	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	9	feasible	\N
18497	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	9	feasible	\N
18498	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	9	feasible	\N
18499	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	9	feasible	\N
18500	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	9	feasible	\N
18501	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	9	feasible	\N
18502	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	9	feasible	\N
18503	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	9	feasible	\N
18504	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	9	feasible	\N
18505	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	9	feasible	\N
18506	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	9	feasible	\N
18507	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	9	feasible	\N
18508	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	9	feasible	\N
18509	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	9	feasible	\N
18510	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	9	feasible	\N
18511	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	9	feasible	\N
18512	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	9	feasible	\N
18513	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	9	feasible	\N
18514	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	9	feasible	\N
18515	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	9	feasible	\N
18516	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	9	feasible	\N
18517	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	9	feasible	\N
18518	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	9	feasible	\N
18519	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	9	feasible	\N
18520	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	9	feasible	\N
18521	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	9	feasible	\N
18522	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	9	feasible	\N
18523	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	9	feasible	\N
18524	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	9	feasible	\N
18525	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	9	feasible	\N
18526	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	9	feasible	\N
18527	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	9	help	\N
18528	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	9	feasible	\N
18529	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	9	help	\N
18530	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	9	help	\N
18531	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	10	feasible	\N
18532	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	10	feasible	\N
18533	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	10	feasible	\N
18534	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	10	feasible	\N
18535	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	10	feasible	\N
18536	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	10	feasible	\N
18537	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	10	feasible	\N
18538	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	10	feasible	\N
18539	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	10	feasible	\N
18540	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	10	feasible	\N
18541	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	10	feasible	\N
18542	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	10	feasible	\N
18543	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	10	feasible	\N
18544	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	10	feasible	\N
18545	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	10	feasible	\N
18546	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	10	feasible	\N
18547	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	10	feasible	\N
18548	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	10	feasible	\N
18549	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	10	feasible	\N
18550	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	10	feasible	\N
18551	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	10	feasible	\N
18552	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	10	feasible	\N
18553	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	10	feasible	\N
18554	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	10	feasible	\N
18555	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	10	feasible	\N
18556	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	10	feasible	\N
18557	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	10	feasible	\N
18558	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	10	feasible	\N
18559	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	10	feasible	\N
18560	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	10	feasible	\N
18561	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	10	feasible	\N
18562	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	10	feasible	\N
18563	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	10	feasible	\N
18564	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	10	feasible	\N
18565	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	10	feasible	\N
18566	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	10	feasible	\N
18567	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	10	feasible	\N
18568	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	10	feasible	\N
18569	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	10	feasible	\N
18570	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	10	feasible	\N
18571	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	10	feasible	\N
18572	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	10	feasible	\N
18573	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	10	feasible	\N
18574	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	10	feasible	\N
18575	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	10	feasible	\N
18576	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	10	feasible	\N
18577	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	10	feasible	\N
18578	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	10	feasible	\N
18579	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	10	feasible	\N
18580	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	10	feasible	\N
18581	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	10	feasible	\N
18582	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	10	feasible	\N
18583	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	10	feasible	\N
18584	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	10	feasible	\N
18585	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	10	feasible	\N
18586	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	10	feasible	\N
18587	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	10	feasible	\N
18588	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	10	feasible	\N
18589	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	10	feasible	\N
18590	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	10	feasible	\N
18591	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	10	feasible	\N
18592	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	10	feasible	\N
18593	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	10	feasible	\N
18594	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	10	feasible	\N
18595	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	10	feasible	\N
18596	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	10	feasible	\N
18597	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	10	feasible	\N
18598	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	10	feasible	\N
18599	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	10	feasible	\N
18600	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	10	feasible	\N
18601	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	10	feasible	\N
18602	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	10	feasible	\N
18603	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	10	feasible	\N
18604	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	10	feasible	\N
18605	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	10	feasible	\N
18606	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	10	feasible	\N
18607	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	10	feasible	\N
18608	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	10	feasible	\N
18609	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	10	feasible	\N
18610	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	10	feasible	\N
18611	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	10	feasible	\N
18612	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	10	feasible	\N
18613	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	10	feasible	\N
18614	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	10	feasible	\N
18615	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	10	feasible	\N
18616	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	10	feasible	\N
18617	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	11	feasible	\N
18618	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	11	feasible	\N
18619	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	11	feasible	\N
18620	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	11	feasible	\N
18621	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	11	feasible	\N
18622	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	11	feasible	\N
18623	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	11	feasible	\N
18624	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	11	feasible	\N
18625	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	11	feasible	\N
18626	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	11	feasible	\N
18627	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	11	feasible	\N
18628	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	11	feasible	\N
18629	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	11	feasible	\N
18630	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	11	feasible	\N
18631	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	11	feasible	\N
18632	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	11	feasible	\N
18633	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	11	feasible	\N
18634	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	11	feasible	\N
18635	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	11	feasible	\N
18636	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	11	feasible	\N
18637	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	11	feasible	\N
18638	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	11	feasible	\N
18639	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	11	feasible	\N
18640	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	11	feasible	\N
18641	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	11	feasible	\N
18642	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	11	feasible	\N
18643	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	11	feasible	\N
18644	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	11	feasible	\N
18645	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	11	feasible	\N
18646	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	11	feasible	\N
18647	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	11	feasible	\N
18648	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	11	feasible	\N
18649	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	11	feasible	\N
18650	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	11	feasible	\N
18651	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	11	feasible	\N
18652	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	11	feasible	\N
18653	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	11	feasible	\N
18654	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	11	feasible	\N
18655	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	11	feasible	\N
18656	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	11	feasible	\N
18657	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	11	feasible	\N
18658	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	11	feasible	\N
18659	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	11	feasible	\N
18660	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	11	feasible	\N
18661	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	11	feasible	\N
18662	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	11	feasible	\N
18663	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	11	feasible	\N
18664	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	11	feasible	\N
18665	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	11	feasible	\N
18666	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	11	feasible	\N
18667	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	11	feasible	\N
18668	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	11	feasible	\N
18669	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	11	feasible	\N
18670	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	11	feasible	\N
18671	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	11	feasible	\N
18672	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	11	feasible	\N
18673	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	11	feasible	\N
18674	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	11	feasible	\N
18675	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	11	feasible	\N
18676	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	11	feasible	\N
18677	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	11	feasible	\N
18678	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	11	feasible	\N
18679	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	11	feasible	\N
18680	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	11	feasible	\N
18681	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	11	feasible	\N
18682	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	11	feasible	\N
18683	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	11	feasible	\N
18684	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	11	feasible	\N
18685	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	11	feasible	\N
18686	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	11	feasible	\N
18687	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	11	feasible	\N
18688	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	11	feasible	\N
18689	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	11	feasible	\N
18690	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	11	feasible	\N
18691	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	11	feasible	\N
18692	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	11	feasible	\N
18693	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	11	feasible	\N
18694	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	11	feasible	\N
18695	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	11	feasible	\N
18696	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	11	feasible	\N
18697	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	11	feasible	\N
18698	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	11	feasible	\N
18699	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	11	feasible	\N
18700	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	11	feasible	\N
18701	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	11	feasible	\N
18702	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	11	feasible	\N
18703	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	13	feasible	\N
18704	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	13	feasible	\N
18705	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	13	feasible	\N
18706	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	13	feasible	\N
18707	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	13	feasible	\N
18708	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	13	help	\N
18709	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	13	feasible	\N
18710	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	13	feasible	\N
18711	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	13	feasible	\N
18712	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	13	feasible	\N
18713	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	13	feasible	\N
18714	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	13	feasible	\N
18715	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	13	feasible	\N
18716	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	13	help	\N
18717	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	13	help	\N
18718	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	13	help	\N
18719	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	13	feasible	\N
18720	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	13	feasible	\N
18721	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	13	feasible	\N
18722	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	13	feasible	\N
18723	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	13	feasible	\N
18724	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	13	feasible	\N
18725	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	13	feasible	\N
18726	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	13	feasible	\N
18727	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	13	feasible	\N
18728	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	13	feasible	\N
18729	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	13	help	\N
18730	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	13	help	\N
18731	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	13	feasible	\N
18732	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	13	feasible	\N
18733	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	13	feasible	\N
18734	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	13	help	\N
18735	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	13	help	\N
18736	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	13	feasible	\N
18737	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	13	feasible	\N
18738	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	13	help	\N
18739	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	13	help	\N
18740	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	13	feasible	\N
18741	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	13	feasible	\N
18742	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	13	feasible	\N
18743	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	13	help	\N
18744	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	13	feasible	\N
18745	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	13	feasible	\N
18746	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	13	feasible	\N
18747	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	13	help	\N
18748	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	13	feasible	\N
18749	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	13	feasible	\N
18750	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	13	help	\N
18751	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	13	feasible	\N
18752	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	13	feasible	\N
18753	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	13	feasible	\N
18754	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	13	feasible	\N
18755	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	13	feasible	\N
18756	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	13	feasible	\N
18757	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	13	feasible	\N
18758	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	13	feasible	\N
18759	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	13	feasible	\N
18760	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	13	feasible	\N
18761	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	13	feasible	\N
18762	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	13	feasible	\N
18763	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	13	help	\N
18764	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	13	help	\N
18765	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	13	help	\N
18766	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	13	feasible	\N
18767	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	13	feasible	\N
18768	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	13	help	\N
18769	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	13	help	\N
18770	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	13	help	\N
18771	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	13	help	\N
18772	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	13	help	\N
18773	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	13	help	\N
18774	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	13	feasible	\N
18775	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	13	feasible	\N
18776	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	13	feasible	\N
18777	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	13	feasible	\N
18778	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	13	feasible	\N
18779	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	13	feasible	\N
18780	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	13	feasible	\N
18781	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	13	feasible	\N
18782	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	13	feasible	\N
18783	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	13	feasible	\N
18784	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	13	feasible	\N
18785	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	13	help	\N
18786	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	13	help	\N
18787	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	13	help	\N
18788	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	13	help	\N
18789	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	14	feasible	\N
18790	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	14	feasible	\N
18791	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	14	feasible	\N
18792	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	14	feasible	\N
18793	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	14	feasible	\N
18794	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	14	feasible	\N
18795	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	14	feasible	\N
18796	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	14	feasible	\N
18797	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	14	feasible	\N
18798	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	14	feasible	\N
18799	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	14	feasible	\N
18800	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	14	feasible	\N
18801	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	14	feasible	\N
18802	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	14	feasible	\N
18803	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	14	help	\N
18804	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	14	help	\N
18805	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	14	feasible	\N
18806	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	14	feasible	\N
18807	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	14	feasible	\N
18808	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	14	feasible	\N
18809	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	14	feasible	\N
18810	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	14	feasible	\N
18811	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	14	feasible	\N
18812	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	14	feasible	\N
18813	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	14	feasible	\N
18814	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	14	feasible	\N
18815	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	14	feasible	\N
18816	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	14	feasible	\N
18817	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	14	feasible	\N
18818	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	14	feasible	\N
18819	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	14	feasible	\N
18820	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	14	feasible	\N
18821	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	14	feasible	\N
18822	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	14	feasible	\N
18823	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	14	help	\N
18824	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	14	help	\N
18825	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	14	help	\N
18826	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	14	help	\N
18827	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	14	feasible	\N
18828	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	14	feasible	\N
18829	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	14	help	\N
18830	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	14	help	\N
18831	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	14	feasible	\N
18832	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	14	feasible	\N
18833	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	14	help	\N
18834	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	14	feasible	\N
18835	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	14	feasible	\N
18836	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	14	help	\N
18837	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	14	help	\N
18838	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	14	help	\N
18839	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	14	feasible	\N
18840	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	14	feasible	\N
18841	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	14	feasible	\N
18842	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	14	feasible	\N
18843	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	14	feasible	\N
18844	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	14	feasible	\N
18845	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	14	feasible	\N
18846	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	14	feasible	\N
18847	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	14	feasible	\N
18848	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	14	feasible	\N
18849	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	14	help	\N
18850	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	14	help	\N
18851	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	14	help	\N
18852	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	14	feasible	\N
18853	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	14	feasible	\N
18854	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	14	feasible	\N
18855	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	14	feasible	\N
18856	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	14	feasible	\N
18857	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	14	feasible	\N
18858	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	14	feasible	\N
18859	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	14	feasible	\N
18860	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	14	feasible	\N
18861	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	14	feasible	\N
18862	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	14	feasible	\N
18863	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	14	feasible	\N
18864	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	14	feasible	\N
18865	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	14	feasible	\N
18866	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	14	feasible	\N
18867	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	14	feasible	\N
18868	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	14	feasible	\N
18869	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	14	feasible	\N
18870	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	14	feasible	\N
18871	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	14	help	\N
18872	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	14	help	\N
18873	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	14	help	\N
18874	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	14	help	\N
18875	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	15	feasible	\N
18876	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	15	feasible	\N
18877	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	15	feasible	\N
18878	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	15	feasible	\N
18879	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	15	feasible	\N
18880	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	15	feasible	\N
18881	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	15	feasible	\N
18882	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	15	feasible	\N
18883	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	15	feasible	\N
18884	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	15	feasible	\N
18885	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	15	feasible	\N
18886	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	15	feasible	\N
18887	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	15	feasible	\N
18888	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	15	feasible	\N
18889	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	15	help	\N
18890	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	15	help	\N
18891	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	15	feasible	\N
18892	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	15	feasible	\N
18893	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	15	feasible	\N
18894	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	15	feasible	\N
18895	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	15	feasible	\N
18896	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	15	feasible	\N
18897	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	15	feasible	\N
18898	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	15	feasible	\N
18899	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	15	feasible	\N
18900	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	15	feasible	\N
18901	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	15	feasible	\N
18902	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	15	feasible	\N
18903	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	15	feasible	\N
18904	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	15	feasible	\N
18905	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	15	feasible	\N
18906	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	15	feasible	\N
18907	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	15	feasible	\N
18908	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	15	feasible	\N
18909	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	15	help	\N
18910	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	15	help	\N
18911	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	15	help	\N
18912	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	15	help	\N
18913	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	15	feasible	\N
18914	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	15	feasible	\N
18915	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	15	help	\N
18916	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	15	help	\N
18917	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	15	feasible	\N
18918	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	15	feasible	\N
18919	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	15	help	\N
18920	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	15	feasible	\N
18921	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	15	feasible	\N
18922	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	15	help	\N
18923	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	15	help	\N
18924	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	15	help	\N
18925	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	15	feasible	\N
18926	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	15	feasible	\N
18927	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	15	feasible	\N
18928	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	15	feasible	\N
18929	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	15	feasible	\N
18930	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	15	feasible	\N
18931	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	15	feasible	\N
18932	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	15	feasible	\N
18933	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	15	feasible	\N
18934	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	15	feasible	\N
18935	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	15	help	\N
18936	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	15	help	\N
18937	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	15	help	\N
18938	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	15	feasible	\N
18939	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	15	feasible	\N
18940	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	15	feasible	\N
18941	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	15	feasible	\N
18942	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	15	feasible	\N
18943	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	15	feasible	\N
18944	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	15	feasible	\N
18945	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	15	feasible	\N
18946	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	15	feasible	\N
18947	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	15	feasible	\N
18948	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	15	feasible	\N
18949	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	15	feasible	\N
18950	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	15	feasible	\N
18951	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	15	feasible	\N
18952	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	15	feasible	\N
18953	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	15	feasible	\N
18954	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	15	feasible	\N
18955	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	15	feasible	\N
18956	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	15	feasible	\N
18957	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	15	help	\N
18958	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	15	help	\N
18959	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	15	help	\N
18960	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	15	help	\N
18961	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	16	feasible	\N
18962	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	16	feasible	\N
18963	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	16	feasible	\N
18964	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	16	feasible	\N
18965	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	16	feasible	\N
18966	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	16	feasible	\N
18967	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	16	feasible	\N
18968	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	16	feasible	\N
18969	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	16	feasible	\N
18970	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	16	feasible	\N
18971	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	16	feasible	\N
18972	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	16	feasible	\N
18973	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	16	feasible	\N
18974	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	16	feasible	\N
18975	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	16	help	\N
18976	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	16	help	\N
18977	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	16	feasible	\N
18978	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	16	feasible	\N
18979	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	16	feasible	\N
18980	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	16	feasible	\N
18981	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	16	feasible	\N
18982	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	16	feasible	\N
18983	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	16	feasible	\N
18984	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	16	feasible	\N
18985	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	16	feasible	\N
18986	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	16	feasible	\N
18987	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	16	feasible	\N
18988	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	16	feasible	\N
18989	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	16	feasible	\N
18990	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	16	feasible	\N
18991	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	16	feasible	\N
18992	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	16	feasible	\N
18993	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	16	feasible	\N
18994	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	16	feasible	\N
18995	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	16	help	\N
18996	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	16	help	\N
18997	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	16	help	\N
18998	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	16	help	\N
18999	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	16	feasible	\N
19000	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	16	feasible	\N
19001	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	16	help	\N
19002	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	16	help	\N
19003	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	16	feasible	\N
19004	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	16	feasible	\N
19005	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	16	help	\N
19006	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	16	feasible	\N
19007	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	16	feasible	\N
19008	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	16	help	\N
19009	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	16	help	\N
19010	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	16	help	\N
19011	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	16	feasible	\N
19012	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	16	feasible	\N
19013	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	16	feasible	\N
19014	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	16	feasible	\N
19015	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	16	feasible	\N
19016	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	16	feasible	\N
19017	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	16	feasible	\N
19018	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	16	feasible	\N
19019	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	16	feasible	\N
19020	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	16	feasible	\N
19021	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	16	help	\N
19022	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	16	help	\N
19023	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	16	help	\N
19024	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	16	feasible	\N
19025	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	16	feasible	\N
19026	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	16	feasible	\N
19027	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	16	feasible	\N
19028	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	16	feasible	\N
19029	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	16	feasible	\N
19030	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	16	feasible	\N
19031	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	16	feasible	\N
19032	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	16	feasible	\N
19033	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	16	feasible	\N
19034	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	16	feasible	\N
19035	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	16	feasible	\N
19036	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	16	feasible	\N
19037	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	16	feasible	\N
19038	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	16	feasible	\N
19039	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	16	feasible	\N
19040	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	16	feasible	\N
19041	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	16	feasible	\N
19042	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	16	feasible	\N
19043	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	16	help	\N
19044	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	16	help	\N
19045	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	16	help	\N
19046	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	16	help	\N
19047	00000000-0000-0000-0000-000000000002	f19e95a7-6784-4404-9439-3d06375052c4	17	feasible	\N
19048	00000000-0000-0000-0000-000000000002	52526ddb-047c-4b92-8d0e-a7291a27ce49	17	feasible	\N
19049	00000000-0000-0000-0000-000000000002	89349d30-7ec7-41c5-8e69-ae2523d091b1	17	feasible	\N
19050	00000000-0000-0000-0000-000000000002	82c24af6-c5cc-4a56-b2f7-aaf71e530c86	17	feasible	\N
19051	00000000-0000-0000-0000-000000000002	4762078d-3f3d-40dc-be03-7deecc268f09	17	feasible	\N
19052	00000000-0000-0000-0000-000000000002	36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	17	feasible	\N
19053	00000000-0000-0000-0000-000000000002	2ea94914-76ba-427e-9bbc-18d4ee9e5774	17	feasible	\N
19054	00000000-0000-0000-0000-000000000002	e7e79523-99e2-431f-a396-614beff15e8d	17	feasible	\N
19055	00000000-0000-0000-0000-000000000002	be5ff0e9-bba2-49dd-b429-019151e7f023	17	feasible	\N
19056	00000000-0000-0000-0000-000000000002	33b1b591-1408-4ca3-9c90-3df731e663e1	17	feasible	\N
19057	00000000-0000-0000-0000-000000000002	5e76824c-7c69-4cda-8d7d-90f00906b9bd	17	feasible	\N
19058	00000000-0000-0000-0000-000000000002	bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	17	feasible	\N
19059	00000000-0000-0000-0000-000000000002	94cc94fb-38df-49e0-9613-c5a263efcde2	17	feasible	\N
19060	00000000-0000-0000-0000-000000000002	f86969d8-6b47-49b7-8a93-c4e1ca454deb	17	feasible	\N
19061	00000000-0000-0000-0000-000000000002	fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	17	feasible	\N
19062	00000000-0000-0000-0000-000000000002	efd4ab61-1383-4ca9-83cc-b7f664940970	17	feasible	\N
19063	00000000-0000-0000-0000-000000000002	07f67a0b-a495-47e0-8239-cee51b2f6a9d	17	feasible	\N
19064	00000000-0000-0000-0000-000000000002	3ffed387-340b-449f-b9af-dcd39a03636b	17	feasible	\N
19065	00000000-0000-0000-0000-000000000002	d3264608-214e-4c75-a138-5295d0d58aed	17	feasible	\N
19066	00000000-0000-0000-0000-000000000002	6f7b6d10-ed04-4042-9ace-9a87fa2b599b	17	feasible	\N
19067	00000000-0000-0000-0000-000000000002	3a96ac9b-4d3e-4e74-9839-ecab592182b3	17	feasible	\N
19068	00000000-0000-0000-0000-000000000002	0f5ec0ef-7554-4cd0-8853-1c65194e3f05	17	feasible	\N
19069	00000000-0000-0000-0000-000000000002	fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	17	feasible	\N
19070	00000000-0000-0000-0000-000000000002	6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	17	feasible	\N
19071	00000000-0000-0000-0000-000000000002	083afefb-71bc-4cef-bbb7-e85fb20e78e0	17	feasible	\N
19072	00000000-0000-0000-0000-000000000002	778fe89b-feae-43d4-bcae-f48be671fe3e	17	feasible	\N
19073	00000000-0000-0000-0000-000000000002	456bb632-f154-4da5-88e5-c9ae74d17b20	17	feasible	\N
19074	00000000-0000-0000-0000-000000000002	b7552017-0f9c-42fe-982c-188524138d82	17	feasible	\N
19075	00000000-0000-0000-0000-000000000002	c24f8551-618a-40da-b4d7-446991ec035f	17	feasible	\N
19076	00000000-0000-0000-0000-000000000002	96d53cfd-cc5c-4d22-8481-586296070ca1	17	feasible	\N
19077	00000000-0000-0000-0000-000000000002	f61600c3-e129-443f-aa56-775103d1b894	17	feasible	\N
19078	00000000-0000-0000-0000-000000000002	7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	17	feasible	\N
19079	00000000-0000-0000-0000-000000000002	81d91a82-d222-4e9a-9ced-a0a6a22d0088	17	feasible	\N
19080	00000000-0000-0000-0000-000000000002	501fe9df-f89e-414b-83b2-ddebc5fe0b64	17	feasible	\N
19081	00000000-0000-0000-0000-000000000002	f950e74c-93b1-4dd6-b368-36a0a355ec9a	17	feasible	\N
19082	00000000-0000-0000-0000-000000000002	6f69ca98-8158-4cf1-8be8-fc2d29043fcc	17	feasible	\N
19083	00000000-0000-0000-0000-000000000002	57b8cea3-e2f6-4fcb-9034-9a068363611a	17	feasible	\N
19084	00000000-0000-0000-0000-000000000002	5a98d80e-dfcc-441c-86ab-a58650e434f0	17	feasible	\N
19085	00000000-0000-0000-0000-000000000002	f7451450-1192-4c4e-bc16-054e0c112c5b	17	feasible	\N
19086	00000000-0000-0000-0000-000000000002	f17d762b-ae98-42cd-9ccf-598f45d14371	17	feasible	\N
19087	00000000-0000-0000-0000-000000000002	ff554745-07c5-453b-9f34-906e28487689	17	feasible	\N
19088	00000000-0000-0000-0000-000000000002	4275e3d6-6d1e-4a1d-ad33-4a041c19d651	17	feasible	\N
19089	00000000-0000-0000-0000-000000000002	e552ccfc-0b95-4a44-bd73-5358e1662869	17	feasible	\N
19090	00000000-0000-0000-0000-000000000002	802c3e45-96a5-4f46-b3d0-161210ca609b	17	feasible	\N
19091	00000000-0000-0000-0000-000000000002	69e27413-9b0a-4f69-adbf-f66e2e6f5fef	17	feasible	\N
19092	00000000-0000-0000-0000-000000000002	b7fc98e6-9785-4243-baae-7725c0c145d8	17	feasible	\N
19093	00000000-0000-0000-0000-000000000002	1a4425b1-fb11-425b-848f-c872c824a7b6	17	feasible	\N
19094	00000000-0000-0000-0000-000000000002	14ef29da-9dc0-4410-9569-5b2750a874c6	17	feasible	\N
19095	00000000-0000-0000-0000-000000000002	e0c28d54-8dc7-4381-a813-5cc4d87296d9	17	feasible	\N
19096	00000000-0000-0000-0000-000000000002	d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	17	feasible	\N
19097	00000000-0000-0000-0000-000000000002	0ee39207-9f91-49c1-879f-4ac09ae8d404	17	feasible	\N
19098	00000000-0000-0000-0000-000000000002	0da905af-8158-4c9e-989f-9cc2fb41c442	17	feasible	\N
19099	00000000-0000-0000-0000-000000000002	275e50d9-f25c-44e5-a4cd-ce2f9cbee185	17	feasible	\N
19100	00000000-0000-0000-0000-000000000002	ff9dbcba-8e9b-48cb-b69e-e14842ceccde	17	feasible	\N
19101	00000000-0000-0000-0000-000000000002	8cb53f78-04fa-4c3b-873a-17596dcf13fa	17	feasible	\N
19102	00000000-0000-0000-0000-000000000002	5000bf4f-7731-4473-94b1-bcc09b94f7c0	17	feasible	\N
19103	00000000-0000-0000-0000-000000000002	d671083b-e732-4663-81d3-933a9e8d1306	17	feasible	\N
19104	00000000-0000-0000-0000-000000000002	6661b5c3-9f7e-4c3d-ad70-870678573078	17	feasible	\N
19105	00000000-0000-0000-0000-000000000002	5df81697-759a-4ef9-bb5c-fd119bde2d7c	17	feasible	\N
19106	00000000-0000-0000-0000-000000000002	07b84a37-24cd-4d42-a3a4-68cae22132cd	17	feasible	\N
19107	00000000-0000-0000-0000-000000000002	075e8e0a-0aea-47c2-bb85-6af7395458c8	17	feasible	\N
19108	00000000-0000-0000-0000-000000000002	fa29dbe9-ca50-4de4-98a4-ef053839cee2	17	feasible	\N
19109	00000000-0000-0000-0000-000000000002	ce52f972-8025-48f3-8c81-363cc75ce889	17	feasible	\N
19110	00000000-0000-0000-0000-000000000002	393036db-fd97-4584-be13-5927bb0192b5	17	feasible	\N
19111	00000000-0000-0000-0000-000000000002	c85d88f2-c477-45b1-bb5c-78f9322f8904	17	feasible	\N
19112	00000000-0000-0000-0000-000000000002	5731ff9d-e192-4014-9c18-febd5a54d807	17	feasible	\N
19113	00000000-0000-0000-0000-000000000002	40fbec4c-4e13-4af3-99c5-15880f06c093	17	feasible	\N
19114	00000000-0000-0000-0000-000000000002	a29c54e4-4cf6-4e2b-97a2-47146af20d44	17	feasible	\N
19115	00000000-0000-0000-0000-000000000002	33296af7-eeac-44f6-a4a4-e581adeb6616	17	feasible	\N
19116	00000000-0000-0000-0000-000000000002	6e2f6ab0-f3aa-475d-b60a-b59474e213ae	17	feasible	\N
19117	00000000-0000-0000-0000-000000000002	b0e8c9f7-f53e-45c9-9602-e30e74347e18	17	feasible	\N
19118	00000000-0000-0000-0000-000000000002	f91950b0-e3cf-4356-a974-d69efbfcd558	17	feasible	\N
19119	00000000-0000-0000-0000-000000000002	813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	17	feasible	\N
19120	00000000-0000-0000-0000-000000000002	48923d9b-e4ea-4046-9849-8b77c2becc48	17	feasible	\N
19121	00000000-0000-0000-0000-000000000002	df062558-273a-4d2e-9087-d72678edf812	17	feasible	\N
19122	00000000-0000-0000-0000-000000000002	9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	17	feasible	\N
19123	00000000-0000-0000-0000-000000000002	7b5a707d-a515-4175-8a7d-09da87034090	17	feasible	\N
19124	00000000-0000-0000-0000-000000000002	7b44ae7b-9fbd-48e5-b872-4be2685dee5e	17	feasible	\N
19125	00000000-0000-0000-0000-000000000002	aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	17	feasible	\N
19126	00000000-0000-0000-0000-000000000002	386d9b5a-1220-4121-b3df-01e145e71566	17	feasible	\N
19127	00000000-0000-0000-0000-000000000002	da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	17	feasible	\N
19128	00000000-0000-0000-0000-000000000002	5f1efc2a-d477-4234-9dfb-f2bbb9579a91	17	feasible	\N
19129	00000000-0000-0000-0000-000000000002	11739645-8215-4889-8cfe-c6eccbeaa9c6	17	help	\N
19130	00000000-0000-0000-0000-000000000002	80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	17	feasible	\N
19131	00000000-0000-0000-0000-000000000002	9a809e7c-1379-4594-900f-da7158244098	17	help	\N
19132	00000000-0000-0000-0000-000000000002	164610c1-4de1-427c-ae67-6a81950b0314	17	help	\N
19133	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	1	feasible	\N
19134	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	1	feasible	\N
19135	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	1	feasible	\N
19136	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	1	feasible	\N
19137	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	1	feasible	\N
19138	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	1	feasible	\N
19139	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	1	feasible	\N
19140	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	1	feasible	\N
19141	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	1	feasible	\N
19142	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	1	feasible	\N
19143	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	1	feasible	\N
19144	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	1	feasible	\N
19145	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	1	feasible	\N
19146	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	1	feasible	\N
19147	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	1	feasible	\N
19148	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	1	feasible	\N
19149	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	1	feasible	\N
19150	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	1	feasible	\N
19151	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	1	feasible	\N
19152	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	1	feasible	\N
19153	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	1	feasible	\N
19154	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	1	feasible	\N
19155	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	1	feasible	\N
19156	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	1	feasible	\N
19157	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	1	feasible	\N
19158	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	1	feasible	\N
19159	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	1	feasible	\N
19160	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	1	feasible	\N
19161	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	1	feasible	\N
19162	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	1	feasible	\N
19163	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	1	feasible	\N
19164	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	1	feasible	\N
19165	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	1	feasible	\N
19166	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	1	feasible	\N
19167	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	1	feasible	\N
19168	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	1	feasible	\N
19169	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	1	feasible	\N
19170	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	1	feasible	\N
19171	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	1	feasible	\N
19172	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	1	feasible	\N
19173	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	1	feasible	\N
19174	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	1	help	\N
19175	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	1	feasible	\N
19176	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	1	feasible	\N
19177	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	1	feasible	\N
19178	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	1	feasible	\N
19179	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	1	feasible	\N
19180	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	1	feasible	\N
19181	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	1	feasible	\N
19182	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	1	feasible	\N
19183	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	1	feasible	\N
19184	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	1	feasible	\N
19185	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	1	feasible	\N
19186	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	1	feasible	\N
19187	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	1	feasible	\N
19188	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	1	feasible	\N
19189	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	1	feasible	\N
19190	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	1	feasible	\N
19191	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	1	feasible	\N
19192	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	1	feasible	\N
19193	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	1	feasible	\N
19194	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	1	feasible	\N
19195	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	1	feasible	\N
19196	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	1	feasible	\N
19197	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	1	feasible	\N
19198	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	1	feasible	\N
19199	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	1	feasible	\N
19200	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	1	feasible	\N
19201	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	1	feasible	\N
19202	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	1	feasible	\N
19203	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	1	feasible	\N
19204	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	1	feasible	\N
19205	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	1	feasible	\N
19206	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	1	feasible	\N
19207	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	1	feasible	\N
19208	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	1	feasible	\N
19209	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	1	feasible	\N
19210	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	1	feasible	\N
19211	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	1	feasible	\N
19212	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	1	feasible	\N
19213	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	1	feasible	\N
19214	00000000-0000-0000-0000-000000000003	bd27b930-c86c-4cb7-bfa0-0c02866bd500	1	feasible	\N
19215	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	1	feasible	\N
19216	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	1	feasible	\N
19217	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	1	feasible	\N
19218	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	1	feasible	\N
19219	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	1	feasible	\N
19220	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	1	feasible	\N
19221	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	1	feasible	\N
19222	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	1	feasible	\N
19223	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	1	feasible	\N
19224	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	1	feasible	\N
19225	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	1	feasible	\N
19226	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	1	feasible	\N
19227	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	1	feasible	\N
19228	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	1	feasible	\N
19229	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	1	feasible	\N
19230	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	1	feasible	\N
19231	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	1	feasible	\N
19232	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	1	feasible	\N
19233	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	1	feasible	\N
19234	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	1	feasible	\N
19235	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	1	feasible	\N
19236	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	1	feasible	\N
19237	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	1	feasible	\N
19238	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	1	feasible	\N
19239	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	1	feasible	\N
19240	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	1	feasible	\N
19241	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	1	feasible	\N
19242	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	1	feasible	\N
19243	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	1	feasible	\N
19244	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	1	feasible	\N
19245	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	1	feasible	\N
19246	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	1	feasible	\N
19247	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	1	feasible	\N
19248	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	1	feasible	\N
19249	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	1	feasible	\N
19250	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	1	feasible	\N
19251	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	1	feasible	\N
19252	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	1	feasible	\N
19253	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	1	feasible	\N
19254	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	1	feasible	\N
19255	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	1	feasible	\N
19256	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	1	feasible	\N
19257	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	1	feasible	\N
19258	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	1	feasible	\N
19259	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	1	feasible	\N
19260	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	1	feasible	\N
19261	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	1	feasible	\N
19262	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	1	feasible	\N
19263	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	1	feasible	\N
19264	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	1	feasible	\N
19265	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	1	feasible	\N
19266	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	1	feasible	\N
19267	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	1	feasible	\N
19268	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	1	feasible	\N
19269	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	1	feasible	\N
19270	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	1	feasible	\N
19271	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	1	feasible	\N
19272	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	1	feasible	\N
19273	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	1	feasible	\N
19274	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	1	feasible	\N
19275	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	1	feasible	\N
19276	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	1	feasible	\N
19277	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	1	feasible	\N
19278	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	1	feasible	\N
19279	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	1	feasible	\N
19280	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	1	feasible	\N
19281	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	1	feasible	\N
19282	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	1	feasible	\N
19283	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	1	feasible	\N
19284	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	1	feasible	\N
19285	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	1	feasible	\N
19286	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	1	feasible	\N
19287	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	1	feasible	\N
19288	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	1	feasible	\N
19289	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	1	feasible	\N
19290	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	1	feasible	\N
19291	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	1	feasible	\N
19292	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	2	feasible	\N
19293	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	2	feasible	\N
19294	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	2	feasible	\N
19295	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	2	feasible	\N
19296	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	2	feasible	\N
19297	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	2	help	\N
19298	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	2	feasible	\N
19299	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	2	feasible	\N
19300	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	2	feasible	\N
19301	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	2	feasible	\N
19302	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	2	feasible	\N
19303	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	2	feasible	\N
19304	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	2	feasible	\N
19305	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	2	feasible	\N
19306	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	2	help	\N
19307	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	2	feasible	\N
19308	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	2	feasible	\N
19309	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	2	feasible	\N
19310	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	2	feasible	\N
19311	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	2	feasible	\N
19312	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	2	feasible	\N
19313	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	2	feasible	\N
19314	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	2	feasible	\N
19315	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	2	feasible	\N
19316	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	2	feasible	\N
19317	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	2	help	\N
19318	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	2	feasible	\N
19319	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	2	feasible	\N
19320	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	2	feasible	\N
19321	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	2	feasible	\N
19322	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	2	feasible	\N
19323	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	2	feasible	\N
19324	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	2	feasible	\N
19325	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	2	feasible	\N
19326	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	2	feasible	\N
19327	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	2	feasible	\N
19328	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	2	feasible	\N
19329	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	2	feasible	\N
19330	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	2	feasible	\N
19331	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	2	feasible	\N
19332	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	2	feasible	\N
19333	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	2	help	\N
19334	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	2	feasible	\N
19335	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	2	feasible	\N
19336	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	2	feasible	\N
19337	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	2	feasible	\N
19338	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	2	feasible	\N
19339	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	2	feasible	\N
19340	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	2	feasible	\N
19341	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	2	feasible	\N
19342	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	2	feasible	\N
19343	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	2	feasible	\N
19344	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	2	feasible	\N
19345	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	2	feasible	\N
19346	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	2	feasible	\N
19347	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	2	feasible	\N
19348	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	2	feasible	\N
19349	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	2	feasible	\N
19350	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	2	feasible	\N
19351	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	2	feasible	\N
19352	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	2	feasible	\N
19353	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	2	help	\N
19354	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	2	feasible	\N
19355	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	2	feasible	\N
19356	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	2	help	\N
19357	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	2	feasible	\N
19358	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	2	feasible	\N
19359	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	2	feasible	\N
19360	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	2	feasible	\N
19361	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	2	feasible	\N
19362	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	2	feasible	\N
19363	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	2	feasible	\N
19364	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	2	feasible	\N
19365	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	2	feasible	\N
19366	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	2	feasible	\N
19367	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	2	feasible	\N
19368	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	2	feasible	\N
19369	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	2	feasible	\N
19370	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	2	feasible	\N
19371	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	2	feasible	\N
19372	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	2	feasible	\N
19373	00000000-0000-0000-0000-000000000003	bd27b930-c86c-4cb7-bfa0-0c02866bd500	2	feasible	\N
19374	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	2	feasible	\N
19375	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	2	feasible	\N
19376	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	2	feasible	\N
19377	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	2	feasible	\N
19378	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	2	feasible	\N
19379	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	2	feasible	\N
19380	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	2	feasible	\N
19381	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	2	feasible	\N
19382	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	2	feasible	\N
19383	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	2	feasible	\N
19384	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	2	feasible	\N
19385	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	2	feasible	\N
19386	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	2	feasible	\N
19387	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	2	feasible	\N
19388	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	2	feasible	\N
19389	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	2	feasible	\N
19390	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	2	feasible	\N
19391	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	2	feasible	\N
19392	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	2	feasible	\N
19393	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	2	feasible	\N
19394	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	2	feasible	\N
19395	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	2	feasible	\N
19396	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	2	help	\N
19397	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	2	feasible	\N
19398	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	2	feasible	\N
19399	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	2	feasible	\N
19400	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	2	feasible	\N
19401	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	2	feasible	\N
19402	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	2	feasible	\N
19403	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	2	feasible	\N
19404	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	2	feasible	\N
19405	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	2	feasible	\N
19406	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	2	feasible	\N
19407	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	2	feasible	\N
19408	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	2	feasible	\N
19409	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	2	feasible	\N
19410	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	2	feasible	\N
19411	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	2	feasible	\N
19412	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	2	feasible	\N
19413	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	2	feasible	\N
19414	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	2	feasible	\N
19415	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	2	feasible	\N
19416	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	2	feasible	\N
19417	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	2	feasible	\N
19418	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	2	feasible	\N
19419	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	2	feasible	\N
19420	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	2	feasible	\N
19421	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	2	feasible	\N
19422	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	2	feasible	\N
19423	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	2	feasible	\N
19424	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	2	feasible	\N
19425	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	2	feasible	\N
19426	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	2	feasible	\N
19427	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	2	feasible	\N
19428	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	2	help	\N
19429	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	2	feasible	\N
19430	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	2	feasible	\N
19431	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	2	feasible	\N
19432	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	2	feasible	\N
19433	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	2	feasible	\N
19434	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	2	feasible	\N
19435	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	2	feasible	\N
19436	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	2	feasible	\N
19437	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	2	feasible	\N
19438	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	2	feasible	\N
19439	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	2	feasible	\N
19440	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	2	feasible	\N
19441	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	2	feasible	\N
19442	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	2	feasible	\N
19443	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	2	feasible	\N
19444	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	2	feasible	\N
19445	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	2	feasible	\N
19446	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	2	feasible	\N
19447	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	2	feasible	\N
19448	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	2	help	\N
19449	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	2	help	\N
19450	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	2	help	\N
19451	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	3	feasible	\N
19452	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	3	feasible	\N
19453	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	3	feasible	\N
19454	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	3	feasible	\N
19455	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	3	feasible	\N
19456	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	3	help	\N
19457	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	3	feasible	\N
19458	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	3	feasible	\N
19459	00000000-0000-0000-0000-000000000003	f0704eb5-98f1-4972-b242-94f0ad6f3bba	3	feasible	\N
19460	00000000-0000-0000-0000-000000000003	fe79fe8d-1b76-4546-9ef5-2341c40a516f	3	feasible	\N
19461	00000000-0000-0000-0000-000000000003	518b0620-03d6-4115-b57b-523d50dd3744	3	feasible	\N
19462	00000000-0000-0000-0000-000000000003	619dbf9e-5ebd-43e6-b796-63e7db4037f3	3	feasible	\N
19463	00000000-0000-0000-0000-000000000003	e584e84c-e8ba-40ea-8fa9-b2526e1f4d7b	3	feasible	\N
19464	00000000-0000-0000-0000-000000000003	194a9f58-ebf8-48d1-9dc3-69a866e9cf55	3	feasible	\N
19465	00000000-0000-0000-0000-000000000003	f5be434f-16cb-47f4-ae0e-b6cc67815b30	3	help	\N
19466	00000000-0000-0000-0000-000000000003	646aca0b-564f-4410-a6b6-383dfb3b8f12	3	feasible	\N
19467	00000000-0000-0000-0000-000000000003	9deb40f9-cb4b-43bd-9c6c-68b6f1b33744	3	feasible	\N
19468	00000000-0000-0000-0000-000000000003	531543ca-7a31-423c-b84b-4fdf5fc6e1ef	3	feasible	\N
19469	00000000-0000-0000-0000-000000000003	dfdb8220-bf81-4970-b92d-276a46f30f2a	3	feasible	\N
19470	00000000-0000-0000-0000-000000000003	373edbec-cf27-44c6-bdb5-760fac3c4d95	3	feasible	\N
19471	00000000-0000-0000-0000-000000000003	a5f29a8a-84d3-4a17-b3f9-83ad88f7aacb	3	feasible	\N
19472	00000000-0000-0000-0000-000000000003	1147d0ac-cf56-4af2-a1a6-e22c1b6924a4	3	feasible	\N
19473	00000000-0000-0000-0000-000000000003	90a9f83d-59c4-473c-b847-d1b92e8fd894	3	feasible	\N
19474	00000000-0000-0000-0000-000000000003	e1c9ffd7-1605-45c1-9dd4-5c61b7105f68	3	feasible	\N
19475	00000000-0000-0000-0000-000000000003	980fcaa8-4dce-4353-83bc-b4e387fa0de9	3	feasible	\N
19476	00000000-0000-0000-0000-000000000003	8376d443-d43f-41b3-b038-5b41825d43b6	3	help	\N
19477	00000000-0000-0000-0000-000000000003	71abd243-6b8b-4e8a-b57d-df1416e8bf61	3	feasible	\N
19478	00000000-0000-0000-0000-000000000003	5bd80f6f-c1e7-41b5-8f90-9304cb634e77	3	feasible	\N
19479	00000000-0000-0000-0000-000000000003	00f81c31-e54a-4388-9d99-b2d9019b2a1c	3	feasible	\N
19480	00000000-0000-0000-0000-000000000003	7a281159-aff0-42f2-a00e-577d7c05f1ec	3	feasible	\N
19481	00000000-0000-0000-0000-000000000003	c968f18a-586e-41d6-b75e-910c2f29714a	3	feasible	\N
19482	00000000-0000-0000-0000-000000000003	96d01bf8-a977-4487-91e5-d71ff4454d11	3	feasible	\N
19483	00000000-0000-0000-0000-000000000003	58c62667-b3bd-4cd3-bd0a-dfc92a7c9301	3	feasible	\N
19484	00000000-0000-0000-0000-000000000003	619b1fa6-28e2-42b5-99f1-67c64c3f45bc	3	feasible	\N
19485	00000000-0000-0000-0000-000000000003	d1e4db37-5a24-42ca-95f5-fa1a7645162d	3	feasible	\N
19486	00000000-0000-0000-0000-000000000003	e92e0d31-2ded-40b1-8776-a212c57dd04c	3	feasible	\N
19487	00000000-0000-0000-0000-000000000003	3aa178a2-078f-4a09-afe3-ce3e1dc72afe	3	feasible	\N
19488	00000000-0000-0000-0000-000000000003	adf294e9-ea01-43f5-873e-aba6392d9e61	3	feasible	\N
19489	00000000-0000-0000-0000-000000000003	7ad4b4d3-5958-46c0-b54b-6f81d89cb2ad	3	feasible	\N
19490	00000000-0000-0000-0000-000000000003	6b917be4-1c06-4217-9134-c0d806db42f2	3	feasible	\N
19491	00000000-0000-0000-0000-000000000003	83ef8714-7e52-44cf-9145-e891d058b7e5	3	feasible	\N
19492	00000000-0000-0000-0000-000000000003	ed663b5b-c7f1-4b26-a4ab-2f3c3baa0789	3	help	\N
19493	00000000-0000-0000-0000-000000000003	2d0978ab-9302-46a1-b32f-ec74b7202106	3	feasible	\N
19494	00000000-0000-0000-0000-000000000003	72f80da9-dbec-4bc3-8157-d86ddf3be197	3	feasible	\N
19495	00000000-0000-0000-0000-000000000003	4a73058b-3392-45d7-9fa1-215e412643db	3	feasible	\N
19496	00000000-0000-0000-0000-000000000003	6189465d-1539-4662-ac4c-4ca05895b8ca	3	feasible	\N
19497	00000000-0000-0000-0000-000000000003	1577000b-b1a9-414b-bdd2-4759a3c062a1	3	feasible	\N
19498	00000000-0000-0000-0000-000000000003	d33ca546-f779-448d-9813-cf30925ac543	3	feasible	\N
19499	00000000-0000-0000-0000-000000000003	80089617-1462-4fc2-97d1-3fdc7a1c45c4	3	feasible	\N
19500	00000000-0000-0000-0000-000000000003	bcdb602f-3adc-400d-9c64-4d40679ae63b	3	feasible	\N
19501	00000000-0000-0000-0000-000000000003	3cf3992e-60f2-4775-b398-5c02586f8c73	3	feasible	\N
19502	00000000-0000-0000-0000-000000000003	60d46bc0-f37a-4626-bfd9-a561a92f2d4f	3	feasible	\N
19503	00000000-0000-0000-0000-000000000003	f7f265ac-9ac4-403b-9004-4dc73e6584cc	3	feasible	\N
19504	00000000-0000-0000-0000-000000000003	068c76d5-8134-4b96-9b69-e03911b2b45f	3	feasible	\N
19505	00000000-0000-0000-0000-000000000003	871a4fb6-3029-44ac-b870-2114e7ca36d2	3	feasible	\N
19506	00000000-0000-0000-0000-000000000003	2326c028-3b42-45fe-83c3-f12c82a1170c	3	feasible	\N
19507	00000000-0000-0000-0000-000000000003	67af8f24-d446-4afb-ba6b-e761b31d79b4	3	feasible	\N
19508	00000000-0000-0000-0000-000000000003	80e0ba54-29fa-46bb-8f9a-c565d1195eeb	3	feasible	\N
19509	00000000-0000-0000-0000-000000000003	a3f551b8-b62c-401c-929b-0fdac3e8e175	3	feasible	\N
19510	00000000-0000-0000-0000-000000000003	bad133ff-aa7b-4c17-8e15-18409eb06f7c	3	feasible	\N
19511	00000000-0000-0000-0000-000000000003	84ca4261-45d3-4832-aa50-e7bba0ac355c	3	feasible	\N
19512	00000000-0000-0000-0000-000000000003	21bc8ca8-ff21-488f-9c2d-d99a1e460ebe	3	help	\N
19513	00000000-0000-0000-0000-000000000003	5c87c57f-fe2a-435d-9476-3e5f1f380ebf	3	feasible	\N
19514	00000000-0000-0000-0000-000000000003	b9868415-0ca1-46bf-a698-978593cd03a2	3	feasible	\N
19515	00000000-0000-0000-0000-000000000003	7391b8f7-d9ae-459e-9c97-719cf923700c	3	feasible	\N
19516	00000000-0000-0000-0000-000000000003	4bae7649-4d2c-439c-9d02-6999885aac5f	3	feasible	\N
19517	00000000-0000-0000-0000-000000000003	696179fc-1885-4427-85e6-9946df1a7611	3	feasible	\N
19518	00000000-0000-0000-0000-000000000003	3a0c5a85-2f71-4303-95e6-e46e6f974930	3	feasible	\N
19519	00000000-0000-0000-0000-000000000003	17c1a934-f27b-4db7-8cc7-331501d2bf10	3	feasible	\N
19520	00000000-0000-0000-0000-000000000003	a9d995ce-3ef6-4dbf-aefc-eb7585881516	3	feasible	\N
19521	00000000-0000-0000-0000-000000000003	d85b1a78-d1f6-49cd-a7ee-c0300b95582a	3	feasible	\N
19522	00000000-0000-0000-0000-000000000003	c35c6020-7ce5-42c9-9ae8-775acf4d1c88	3	feasible	\N
19523	00000000-0000-0000-0000-000000000003	3be8c7f5-f80f-4813-b9d1-ffd1e81c982a	3	feasible	\N
19524	00000000-0000-0000-0000-000000000003	1f167592-fce0-48f4-ab06-d8dab118f616	3	feasible	\N
19525	00000000-0000-0000-0000-000000000003	e534d46b-9c5e-4100-9d73-59ab2197469f	3	feasible	\N
19526	00000000-0000-0000-0000-000000000003	92377be7-593b-4340-881f-f7f5047f0ac1	3	feasible	\N
19527	00000000-0000-0000-0000-000000000003	5a408249-c161-4e73-a826-a43496a082f3	3	feasible	\N
19528	00000000-0000-0000-0000-000000000003	619bcd3c-4d6f-4326-af52-3c71438756e0	3	feasible	\N
19529	00000000-0000-0000-0000-000000000003	745bdb91-19b3-42a8-b0a0-2249f4e28f18	3	feasible	\N
19530	00000000-0000-0000-0000-000000000003	5aae7587-5b14-4414-a43e-4dee41801bc8	3	feasible	\N
19531	00000000-0000-0000-0000-000000000003	b551183d-b614-4742-8fd9-1f4fe7e19192	3	feasible	\N
19532	00000000-0000-0000-0000-000000000003	ba76e47b-f38c-401f-8e9a-a3f5be662e77	3	feasible	\N
19533	00000000-0000-0000-0000-000000000003	67031e05-6b12-4cc3-84d0-de9269741a2b	3	feasible	\N
19534	00000000-0000-0000-0000-000000000003	71b0b3eb-a7f7-4cbe-b87e-5133a099ffb4	3	feasible	\N
19535	00000000-0000-0000-0000-000000000003	a45fd087-030b-4a15-bf3f-23e7733e9f0e	3	feasible	\N
19536	00000000-0000-0000-0000-000000000003	b1ffd138-e5d2-4dfd-8a6b-c426058ebbf2	3	feasible	\N
19537	00000000-0000-0000-0000-000000000003	eaf5ec2d-b416-4be2-a3d7-fddca1e784b5	3	feasible	\N
19538	00000000-0000-0000-0000-000000000003	79f7fb10-b0ee-4ed3-bcca-cb12a3b72f8a	3	feasible	\N
19539	00000000-0000-0000-0000-000000000003	65574b1c-61b7-4b41-962d-b17b8dc1d4a5	3	feasible	\N
19540	00000000-0000-0000-0000-000000000003	b40556f8-43a6-4c5a-9f1e-f56740ed9a00	3	feasible	\N
19541	00000000-0000-0000-0000-000000000003	6dad898b-aa62-452d-9674-bfa81b134c7e	3	feasible	\N
19542	00000000-0000-0000-0000-000000000003	94e65ba6-dd74-4513-bed9-b7dedba0eb2e	3	feasible	\N
19543	00000000-0000-0000-0000-000000000003	a66888fe-92c4-4548-ba7d-97db23e2a7f2	3	feasible	\N
19544	00000000-0000-0000-0000-000000000003	24c959f3-18d6-4e46-9d0d-bab21058f2d5	3	feasible	\N
19545	00000000-0000-0000-0000-000000000003	3fd85f2b-97b9-41e9-8850-9ee9f2466918	3	feasible	\N
19546	00000000-0000-0000-0000-000000000003	0d8f0247-efaa-4343-acd6-614d1c9d3971	3	feasible	\N
19547	00000000-0000-0000-0000-000000000003	454ae584-3ade-4d6c-995f-d754726d43b7	3	feasible	\N
19548	00000000-0000-0000-0000-000000000003	a98398d6-4de1-4404-8e73-65ae4000244f	3	feasible	\N
19549	00000000-0000-0000-0000-000000000003	4a4d28c2-8932-4361-a390-4fdb93820712	3	feasible	\N
19550	00000000-0000-0000-0000-000000000003	ecbc5672-cbe8-4a7c-b74e-321239f548c5	3	feasible	\N
19551	00000000-0000-0000-0000-000000000003	180f2539-17f3-4075-912b-4b706b294e72	3	feasible	\N
19552	00000000-0000-0000-0000-000000000003	c047fae8-2d62-4eb0-bc03-ec05cd9310c0	3	feasible	\N
19553	00000000-0000-0000-0000-000000000003	fcfc7205-f0b0-4de6-a256-7625d4c65cd2	3	feasible	\N
19554	00000000-0000-0000-0000-000000000003	b75a23a5-a286-4842-96f6-9abac1de1156	3	help	\N
19555	00000000-0000-0000-0000-000000000003	7903e0fc-aa7d-4b13-b49a-5b6e297c87b5	3	feasible	\N
19556	00000000-0000-0000-0000-000000000003	0666d99d-44b2-4c15-94be-a929a3d8b43e	3	feasible	\N
19557	00000000-0000-0000-0000-000000000003	8b687a8e-eaa3-4e06-a664-b5a6a4447155	3	feasible	\N
19558	00000000-0000-0000-0000-000000000003	79019cce-b13e-425e-86f1-d1c0b226650f	3	feasible	\N
19559	00000000-0000-0000-0000-000000000003	3ade4f3c-d46f-4409-bcf7-d7bcf617de07	3	feasible	\N
19560	00000000-0000-0000-0000-000000000003	19b94cfa-92bc-4c1b-898e-a466270a846c	3	feasible	\N
19561	00000000-0000-0000-0000-000000000003	b3952e94-3bbf-454f-a510-c116a9646fe2	3	feasible	\N
19562	00000000-0000-0000-0000-000000000003	4099170f-0e50-4050-9de5-38529094d8a2	3	feasible	\N
19563	00000000-0000-0000-0000-000000000003	aec6af48-8c68-4417-8ac2-cf4a039db1f0	3	feasible	\N
19564	00000000-0000-0000-0000-000000000003	24d96554-ac13-4cc8-bb2f-092304c678ab	3	feasible	\N
19565	00000000-0000-0000-0000-000000000003	df29d8dd-a4dd-424c-b7b7-cb4b379cdb16	3	feasible	\N
19566	00000000-0000-0000-0000-000000000003	2549ae79-1a34-4a0d-9ea9-c355982de1af	3	feasible	\N
19567	00000000-0000-0000-0000-000000000003	fe081bbf-8016-4e21-8906-2d62a6ae3d6e	3	feasible	\N
19568	00000000-0000-0000-0000-000000000003	9f815a08-5698-47bd-aa23-20d39143539a	3	feasible	\N
19569	00000000-0000-0000-0000-000000000003	0d367c27-1b3a-4c7c-938b-b08d40e538e3	3	feasible	\N
19570	00000000-0000-0000-0000-000000000003	b1bab347-e36d-4531-8c01-706f8ebf0b6d	3	feasible	\N
19571	00000000-0000-0000-0000-000000000003	f7ac92d1-14aa-41a6-bb0d-3dfe107a5c51	3	feasible	\N
19572	00000000-0000-0000-0000-000000000003	d1f2deac-da1f-4d3c-9378-dda9d48cefc0	3	feasible	\N
19573	00000000-0000-0000-0000-000000000003	04fc7e24-26f9-4d92-b9c3-0b4895586177	3	feasible	\N
19574	00000000-0000-0000-0000-000000000003	99c914b9-0c1f-4af9-b40b-41bf0e93237f	3	feasible	\N
19575	00000000-0000-0000-0000-000000000003	4a80c54a-05b1-4834-839a-a24ce4198d8d	3	feasible	\N
19576	00000000-0000-0000-0000-000000000003	9a970ac8-0f39-4a73-8a53-9b63cbc3fce3	3	feasible	\N
19577	00000000-0000-0000-0000-000000000003	28852677-7717-4564-8fd9-42db5516df97	3	feasible	\N
19578	00000000-0000-0000-0000-000000000003	a5e8906d-68a3-450f-b306-14771f86b533	3	feasible	\N
19579	00000000-0000-0000-0000-000000000003	0c49c197-f9da-44bf-993f-9d4d4939048b	3	feasible	\N
19580	00000000-0000-0000-0000-000000000003	3db27605-e7ed-4310-9dae-db087d232e21	3	feasible	\N
19581	00000000-0000-0000-0000-000000000003	f9056fc4-6774-456f-a6a1-debb8ffcdbb6	3	feasible	\N
19582	00000000-0000-0000-0000-000000000003	db88f222-9e5f-4eea-ad8f-78b8b324139a	3	help	\N
19583	00000000-0000-0000-0000-000000000003	373bfd6d-b769-48cd-a6a0-d51308d98b06	3	feasible	\N
19584	00000000-0000-0000-0000-000000000003	fe049fa9-7af5-4b27-b744-4a36076b2ff1	3	feasible	\N
19585	00000000-0000-0000-0000-000000000003	2071294f-e736-4d92-a6fc-092471fdc25e	3	feasible	\N
19586	00000000-0000-0000-0000-000000000003	4da3ea7d-d1ca-42eb-a34b-1d6d8e3e4ede	3	feasible	\N
19587	00000000-0000-0000-0000-000000000003	dbeb2a22-04e9-47f3-a6e3-5414d47ba57b	3	feasible	\N
19588	00000000-0000-0000-0000-000000000003	9956a0e9-2e1f-4c60-9efc-a5ee748ce704	3	feasible	\N
19589	00000000-0000-0000-0000-000000000003	b7f477d6-f40f-44b3-abd0-de8ff19c91d3	3	feasible	\N
19590	00000000-0000-0000-0000-000000000003	276a0b97-3842-470c-a4c0-79175e1b4927	3	feasible	\N
19591	00000000-0000-0000-0000-000000000003	07f11fd8-a107-4955-9cfb-94548407be49	3	feasible	\N
19592	00000000-0000-0000-0000-000000000003	94b8f229-3cc6-4e63-876a-c587489d6cef	3	feasible	\N
19593	00000000-0000-0000-0000-000000000003	976abcff-7801-47e7-bf81-109f8d8d64d6	3	feasible	\N
19594	00000000-0000-0000-0000-000000000003	8e0913d1-a4f2-47fc-8943-80a905760d3f	3	feasible	\N
19595	00000000-0000-0000-0000-000000000003	63aba3fb-5d8e-4109-83bc-e3d231da5173	3	feasible	\N
19596	00000000-0000-0000-0000-000000000003	65d5c59d-91eb-4c54-9af6-2b2746499189	3	feasible	\N
19597	00000000-0000-0000-0000-000000000003	3910cf58-815c-45c6-8fe3-142bc48029ad	3	feasible	\N
19598	00000000-0000-0000-0000-000000000003	e32d4c0b-bdb3-4ccd-a84c-5b0ddfceb1d7	3	feasible	\N
19599	00000000-0000-0000-0000-000000000003	781630d0-8eeb-4f63-9718-3de081c42134	3	feasible	\N
19600	00000000-0000-0000-0000-000000000003	4622feb4-ea1e-462f-9072-cfdc77ae5d2c	3	feasible	\N
19601	00000000-0000-0000-0000-000000000003	c1afec34-decd-41c0-9acf-accbed9e2de4	3	feasible	\N
19602	00000000-0000-0000-0000-000000000003	605eef49-27d4-4eb3-a2c4-ca2d089a4449	3	help	\N
19603	00000000-0000-0000-0000-000000000003	53f590aa-29fb-4ecd-b206-4651114355b3	3	help	\N
19604	00000000-0000-0000-0000-000000000003	83d9d4f2-fa36-408a-a4e9-5e3c072f4878	3	help	\N
19605	00000000-0000-0000-0000-000000000003	1a96870e-beb8-49e2-b0db-1a4fd1e6345e	3	feasible	\N
19606	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	4	help	\N
19607	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	4	feasible	\N
19608	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	4	feasible	\N
19609	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	4	feasible	\N
19610	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	4	feasible	\N
19611	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	4	feasible	\N
19612	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	4	feasible	\N
19613	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	4	feasible	\N
19614	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	4	feasible	\N
19615	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	4	feasible	\N
19616	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	4	feasible	\N
19617	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	4	feasible	\N
19618	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	4	help	\N
19619	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	4	help	\N
19620	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	4	help	\N
19621	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	4	help	\N
19622	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	4	help	\N
19623	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	4	feasible	\N
19624	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	4	help	\N
19625	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	4	help	\N
19626	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	4	help	\N
19627	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	4	help	\N
19628	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	4	help	\N
19629	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	4	help	\N
19630	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	4	help	\N
19631	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	4	help	\N
19632	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	4	help	\N
19633	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	4	feasible	\N
19634	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	4	help	\N
19635	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	4	help	\N
19636	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	4	help	\N
19637	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	4	help	\N
19638	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	4	help	\N
19639	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	4	help	\N
19640	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	4	help	\N
19641	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	4	help	\N
19642	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	4	help	\N
19643	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	4	help	\N
19644	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	4	help	\N
19645	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	4	help	\N
19646	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	4	help	\N
19647	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	4	help	\N
19648	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	4	help	\N
19649	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	4	help	\N
19650	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	4	help	\N
19651	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	4	help	\N
19652	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	4	feasible	\N
19653	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	4	help	\N
19654	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	4	help	\N
19655	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	4	help	\N
19656	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	4	help	\N
19657	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	4	help	\N
19658	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	4	help	\N
19659	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	4	help	\N
19660	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	4	help	\N
19661	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	4	help	\N
19662	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	4	help	\N
19663	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	4	help	\N
19664	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	4	help	\N
19665	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	4	feasible	\N
19666	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	4	help	\N
19667	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	4	help	\N
19668	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	4	help	\N
19669	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	4	help	\N
19670	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	4	help	\N
19671	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	4	help	\N
19672	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	4	help	\N
19673	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	4	help	\N
19674	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	4	help	\N
19675	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	4	help	\N
19676	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	4	help	\N
19677	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	4	help	\N
19678	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	4	help	\N
19679	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	4	help	\N
19680	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	4	help	\N
19681	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	4	help	\N
19682	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	4	help	\N
19683	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	4	help	\N
19684	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	4	help	\N
19685	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	4	help	\N
19686	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	4	help	\N
19687	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	4	help	\N
19688	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	4	help	\N
19689	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	4	help	\N
19690	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	4	help	\N
19691	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	4	help	\N
19692	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	4	help	\N
19693	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	4	help	\N
19694	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	4	help	\N
19695	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	4	help	\N
19696	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	4	help	\N
19697	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	4	help	\N
19698	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	4	help	\N
19699	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	4	help	\N
19700	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	4	help	\N
19701	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	4	help	\N
19702	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	4	help	\N
19703	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	4	help	\N
19704	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	4	help	\N
19705	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	4	help	\N
19706	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	4	help	\N
19707	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	4	help	\N
19708	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	4	help	\N
19709	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	4	feasible	\N
19710	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	4	help	\N
19711	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	4	feasible	\N
19712	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	4	feasible	\N
19713	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	4	help	\N
19714	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	4	help	\N
19715	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	4	help	\N
19716	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	4	help	\N
19717	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	4	avoid	\N
19718	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	4	feasible	\N
19719	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	4	avoid	\N
19720	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	4	help	\N
19721	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	4	feasible	\N
19722	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	4	avoid	\N
19723	00000000-0000-0000-0000-000000000003	36c2cb3c-1bf7-4eee-b005-29ddea7bec47	4	avoid	\N
19724	00000000-0000-0000-0000-000000000003	41a6358f-09d0-4570-9050-a6cbeaf97db0	4	avoid	\N
19725	00000000-0000-0000-0000-000000000003	ed5a398c-25ef-49cb-9a66-a35cd09fc6ae	4	help	\N
19726	00000000-0000-0000-0000-000000000003	1ccce69a-4a2e-4efc-bd3b-af8c4ed75c53	4	help	\N
19727	00000000-0000-0000-0000-000000000003	10730b18-41c1-43e5-a055-fd68a9f0bb7e	4	help	\N
19728	00000000-0000-0000-0000-000000000003	548efe10-dbbf-420f-9446-12b7aee860d8	4	feasible	\N
19729	00000000-0000-0000-0000-000000000003	5c56bd3d-0876-4e72-b462-b02aeb13838f	4	feasible	\N
19730	00000000-0000-0000-0000-000000000003	c0957b93-d5f0-4bbc-8a85-fc79dfa72365	4	feasible	\N
19731	00000000-0000-0000-0000-000000000003	39047c24-c2c6-43ae-a054-dc36aa805987	4	feasible	\N
19732	00000000-0000-0000-0000-000000000003	e40a7a34-d90e-46cc-b614-a8f2cfbb6011	4	feasible	\N
19733	00000000-0000-0000-0000-000000000003	a0477144-8011-47cc-8188-7ff43ae68e28	4	feasible	\N
19734	00000000-0000-0000-0000-000000000003	5f4c9feb-f853-47ce-afcb-97c1adf9cb7d	4	help	\N
19735	00000000-0000-0000-0000-000000000003	6fbea48f-6b60-481b-ac78-5bb01acf9ac7	4	feasible	\N
19736	00000000-0000-0000-0000-000000000003	35935966-366e-4633-b14b-d08be0c9e885	4	help	\N
19737	00000000-0000-0000-0000-000000000003	155f9ede-ca7e-4ed0-bc36-a49598fe5681	4	help	\N
19738	00000000-0000-0000-0000-000000000003	6a57b2eb-6dc7-421b-b584-68423d7f7685	4	avoid	\N
19739	00000000-0000-0000-0000-000000000003	d289b33b-0461-4110-9cbf-a3858c2ffe23	4	avoid	\N
19740	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	4	help	\N
19741	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	4	help	\N
19742	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	4	help	\N
19743	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	4	avoid	\N
19744	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	4	avoid	\N
19745	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	4	avoid	\N
19746	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	4	avoid	\N
19747	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	4	help	\N
19748	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	4	help	\N
19749	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	4	help	\N
19750	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	4	help	\N
19751	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	4	feasible	\N
19752	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	4	feasible	\N
19753	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	4	feasible	\N
19754	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	4	feasible	\N
19755	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	4	feasible	\N
19756	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	4	feasible	\N
19757	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	4	feasible	\N
19758	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	4	feasible	\N
19759	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	4	feasible	\N
19760	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	4	feasible	\N
19761	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	4	feasible	\N
19762	00000000-0000-0000-0000-000000000003	ebfc1eca-0430-415c-b6d6-1ebaafed3b03	4	feasible	\N
19763	00000000-0000-0000-0000-000000000003	6587c963-aa20-4f51-835d-61ab0150c4c8	4	help	\N
19764	00000000-0000-0000-0000-000000000003	a6bfa460-c021-44ef-9e5a-f9f76f33bd75	4	help	\N
19765	00000000-0000-0000-0000-000000000003	91bb965a-9e68-4bf0-a1c5-9adf48341abc	4	help	\N
19766	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	5	help	\N
19767	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	5	feasible	\N
19768	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	5	feasible	\N
19769	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	5	feasible	\N
19770	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	5	feasible	\N
19771	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	5	feasible	\N
19772	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	5	feasible	\N
19773	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	5	feasible	\N
19774	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	5	feasible	\N
19775	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	5	feasible	\N
19776	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	5	feasible	\N
19777	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	5	feasible	\N
19778	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	5	help	\N
19779	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	5	help	\N
19780	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	5	help	\N
19781	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	5	help	\N
19782	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	5	help	\N
19783	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	5	feasible	\N
19784	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	5	help	\N
19785	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	5	help	\N
19786	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	5	help	\N
19787	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	5	help	\N
19788	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	5	help	\N
19789	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	5	help	\N
19790	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	5	help	\N
19791	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	5	help	\N
19792	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	5	help	\N
19793	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	5	feasible	\N
19794	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	5	help	\N
19795	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	5	help	\N
19796	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	5	help	\N
19797	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	5	help	\N
19798	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	5	help	\N
19799	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	5	help	\N
19800	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	5	help	\N
19801	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	5	help	\N
19802	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	5	help	\N
19803	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	5	help	\N
19804	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	5	help	\N
19805	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	5	help	\N
19806	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	5	help	\N
19807	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	5	help	\N
19808	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	5	help	\N
19809	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	5	help	\N
19810	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	5	help	\N
19811	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	5	help	\N
19812	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	5	feasible	\N
19813	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	5	help	\N
19814	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	5	help	\N
19815	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	5	help	\N
19816	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	5	help	\N
19817	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	5	help	\N
19818	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	5	help	\N
19819	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	5	help	\N
19820	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	5	help	\N
19821	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	5	help	\N
19822	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	5	help	\N
19823	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	5	help	\N
19824	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	5	help	\N
19825	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	5	feasible	\N
19826	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	5	help	\N
19827	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	5	help	\N
19828	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	5	help	\N
19829	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	5	help	\N
19830	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	5	help	\N
19831	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	5	help	\N
19832	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	5	help	\N
19833	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	5	help	\N
19834	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	5	help	\N
19835	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	5	help	\N
19836	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	5	help	\N
19837	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	5	help	\N
19838	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	5	help	\N
19839	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	5	help	\N
19840	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	5	help	\N
19841	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	5	help	\N
19842	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	5	help	\N
19843	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	5	help	\N
19844	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	5	help	\N
19845	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	5	help	\N
19846	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	5	help	\N
19847	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	5	help	\N
19848	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	5	help	\N
19849	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	5	help	\N
19850	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	5	help	\N
19851	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	5	help	\N
19852	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	5	help	\N
19853	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	5	help	\N
19854	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	5	help	\N
19855	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	5	help	\N
19856	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	5	help	\N
19857	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	5	help	\N
19858	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	5	help	\N
19859	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	5	help	\N
19860	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	5	help	\N
19861	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	5	help	\N
19862	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	5	help	\N
19863	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	5	help	\N
19864	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	5	help	\N
19865	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	5	help	\N
19866	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	5	help	\N
19867	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	5	help	\N
19868	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	5	help	\N
19869	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	5	feasible	\N
19870	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	5	help	\N
19871	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	5	feasible	\N
19872	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	5	feasible	\N
19873	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	5	help	\N
19874	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	5	help	\N
19875	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	5	help	\N
19876	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	5	help	\N
19877	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	5	avoid	\N
19878	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	5	feasible	\N
19879	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	5	avoid	\N
19880	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	5	help	\N
19881	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	5	feasible	\N
19882	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	5	avoid	\N
19883	00000000-0000-0000-0000-000000000003	36c2cb3c-1bf7-4eee-b005-29ddea7bec47	5	avoid	\N
19884	00000000-0000-0000-0000-000000000003	41a6358f-09d0-4570-9050-a6cbeaf97db0	5	avoid	\N
19885	00000000-0000-0000-0000-000000000003	ed5a398c-25ef-49cb-9a66-a35cd09fc6ae	5	help	\N
19886	00000000-0000-0000-0000-000000000003	1ccce69a-4a2e-4efc-bd3b-af8c4ed75c53	5	help	\N
19887	00000000-0000-0000-0000-000000000003	10730b18-41c1-43e5-a055-fd68a9f0bb7e	5	help	\N
19888	00000000-0000-0000-0000-000000000003	548efe10-dbbf-420f-9446-12b7aee860d8	5	feasible	\N
19889	00000000-0000-0000-0000-000000000003	5c56bd3d-0876-4e72-b462-b02aeb13838f	5	feasible	\N
19890	00000000-0000-0000-0000-000000000003	c0957b93-d5f0-4bbc-8a85-fc79dfa72365	5	feasible	\N
19891	00000000-0000-0000-0000-000000000003	39047c24-c2c6-43ae-a054-dc36aa805987	5	feasible	\N
19892	00000000-0000-0000-0000-000000000003	e40a7a34-d90e-46cc-b614-a8f2cfbb6011	5	feasible	\N
19893	00000000-0000-0000-0000-000000000003	a0477144-8011-47cc-8188-7ff43ae68e28	5	feasible	\N
19894	00000000-0000-0000-0000-000000000003	5f4c9feb-f853-47ce-afcb-97c1adf9cb7d	5	help	\N
19895	00000000-0000-0000-0000-000000000003	6fbea48f-6b60-481b-ac78-5bb01acf9ac7	5	feasible	\N
19896	00000000-0000-0000-0000-000000000003	35935966-366e-4633-b14b-d08be0c9e885	5	help	\N
19897	00000000-0000-0000-0000-000000000003	155f9ede-ca7e-4ed0-bc36-a49598fe5681	5	help	\N
19898	00000000-0000-0000-0000-000000000003	6a57b2eb-6dc7-421b-b584-68423d7f7685	5	avoid	\N
19899	00000000-0000-0000-0000-000000000003	d289b33b-0461-4110-9cbf-a3858c2ffe23	5	avoid	\N
19900	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	5	help	\N
19901	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	5	help	\N
19902	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	5	help	\N
19903	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	5	avoid	\N
19904	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	5	avoid	\N
19905	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	5	avoid	\N
19906	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	5	avoid	\N
19907	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	5	help	\N
19908	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	5	help	\N
19909	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	5	help	\N
19910	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	5	help	\N
19911	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	5	feasible	\N
19912	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	5	feasible	\N
19913	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	5	feasible	\N
19914	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	5	feasible	\N
19915	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	5	feasible	\N
19916	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	5	feasible	\N
19917	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	5	feasible	\N
19918	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	5	feasible	\N
19919	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	5	feasible	\N
19920	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	5	feasible	\N
19921	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	5	feasible	\N
19922	00000000-0000-0000-0000-000000000003	ebfc1eca-0430-415c-b6d6-1ebaafed3b03	5	feasible	\N
19923	00000000-0000-0000-0000-000000000003	6587c963-aa20-4f51-835d-61ab0150c4c8	5	help	\N
19924	00000000-0000-0000-0000-000000000003	a6bfa460-c021-44ef-9e5a-f9f76f33bd75	5	help	\N
19925	00000000-0000-0000-0000-000000000003	91bb965a-9e68-4bf0-a1c5-9adf48341abc	5	help	\N
19926	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	6	help	\N
19927	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	6	feasible	\N
19928	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	6	feasible	\N
19929	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	6	feasible	\N
19930	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	6	feasible	\N
19931	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	6	feasible	\N
19932	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	6	feasible	\N
19933	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	6	feasible	\N
19934	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	6	feasible	\N
19935	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	6	feasible	\N
19936	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	6	feasible	\N
19937	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	6	feasible	\N
19938	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	6	help	\N
19939	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	6	help	\N
19940	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	6	help	\N
19941	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	6	help	\N
19942	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	6	help	\N
19943	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	6	feasible	\N
19944	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	6	help	\N
19945	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	6	help	\N
19946	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	6	help	\N
19947	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	6	help	\N
19948	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	6	help	\N
19949	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	6	help	\N
19950	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	6	help	\N
19951	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	6	help	\N
19952	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	6	help	\N
19953	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	6	feasible	\N
19954	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	6	help	\N
19955	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	6	help	\N
19956	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	6	help	\N
19957	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	6	help	\N
19958	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	6	help	\N
19959	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	6	help	\N
19960	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	6	help	\N
19961	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	6	help	\N
19962	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	6	help	\N
19963	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	6	help	\N
19964	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	6	help	\N
19965	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	6	help	\N
19966	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	6	help	\N
19967	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	6	help	\N
19968	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	6	help	\N
19969	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	6	help	\N
19970	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	6	help	\N
19971	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	6	help	\N
19972	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	6	feasible	\N
19973	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	6	help	\N
19974	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	6	help	\N
19975	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	6	help	\N
19976	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	6	help	\N
19977	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	6	help	\N
19978	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	6	help	\N
19979	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	6	help	\N
19980	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	6	help	\N
19981	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	6	help	\N
19982	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	6	help	\N
19983	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	6	help	\N
19984	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	6	help	\N
19985	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	6	feasible	\N
19986	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	6	help	\N
19987	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	6	help	\N
19988	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	6	help	\N
19989	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	6	help	\N
19990	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	6	help	\N
19991	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	6	help	\N
19992	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	6	help	\N
19993	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	6	help	\N
19994	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	6	help	\N
19995	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	6	help	\N
19996	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	6	help	\N
19997	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	6	help	\N
19998	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	6	help	\N
19999	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	6	help	\N
20000	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	6	help	\N
20001	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	6	help	\N
20002	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	6	help	\N
20003	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	6	help	\N
20004	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	6	help	\N
20005	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	6	help	\N
20006	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	6	help	\N
20007	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	6	help	\N
20008	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	6	help	\N
20009	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	6	help	\N
20010	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	6	help	\N
20011	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	6	help	\N
20012	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	6	help	\N
20013	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	6	help	\N
20014	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	6	help	\N
20015	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	6	help	\N
20016	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	6	help	\N
20017	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	6	help	\N
20018	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	6	help	\N
20019	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	6	help	\N
20020	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	6	help	\N
20021	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	6	help	\N
20022	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	6	help	\N
20023	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	6	help	\N
20024	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	6	help	\N
20025	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	6	help	\N
20026	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	6	help	\N
20027	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	6	help	\N
20028	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	6	help	\N
20029	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	6	feasible	\N
20030	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	6	help	\N
20031	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	6	feasible	\N
20032	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	6	feasible	\N
20033	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	6	help	\N
20034	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	6	help	\N
20035	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	6	help	\N
20036	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	6	help	\N
20037	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	6	avoid	\N
20038	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	6	feasible	\N
20039	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	6	avoid	\N
20040	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	6	help	\N
20041	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	6	feasible	\N
20042	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	6	avoid	\N
20043	00000000-0000-0000-0000-000000000003	36c2cb3c-1bf7-4eee-b005-29ddea7bec47	6	avoid	\N
20044	00000000-0000-0000-0000-000000000003	41a6358f-09d0-4570-9050-a6cbeaf97db0	6	avoid	\N
20045	00000000-0000-0000-0000-000000000003	ed5a398c-25ef-49cb-9a66-a35cd09fc6ae	6	help	\N
20046	00000000-0000-0000-0000-000000000003	1ccce69a-4a2e-4efc-bd3b-af8c4ed75c53	6	help	\N
20047	00000000-0000-0000-0000-000000000003	10730b18-41c1-43e5-a055-fd68a9f0bb7e	6	help	\N
20048	00000000-0000-0000-0000-000000000003	548efe10-dbbf-420f-9446-12b7aee860d8	6	feasible	\N
20049	00000000-0000-0000-0000-000000000003	5c56bd3d-0876-4e72-b462-b02aeb13838f	6	feasible	\N
20050	00000000-0000-0000-0000-000000000003	c0957b93-d5f0-4bbc-8a85-fc79dfa72365	6	feasible	\N
20051	00000000-0000-0000-0000-000000000003	39047c24-c2c6-43ae-a054-dc36aa805987	6	feasible	\N
20052	00000000-0000-0000-0000-000000000003	e40a7a34-d90e-46cc-b614-a8f2cfbb6011	6	feasible	\N
20053	00000000-0000-0000-0000-000000000003	a0477144-8011-47cc-8188-7ff43ae68e28	6	feasible	\N
20054	00000000-0000-0000-0000-000000000003	5f4c9feb-f853-47ce-afcb-97c1adf9cb7d	6	help	\N
20055	00000000-0000-0000-0000-000000000003	6fbea48f-6b60-481b-ac78-5bb01acf9ac7	6	feasible	\N
20056	00000000-0000-0000-0000-000000000003	35935966-366e-4633-b14b-d08be0c9e885	6	help	\N
20057	00000000-0000-0000-0000-000000000003	155f9ede-ca7e-4ed0-bc36-a49598fe5681	6	help	\N
20058	00000000-0000-0000-0000-000000000003	6a57b2eb-6dc7-421b-b584-68423d7f7685	6	avoid	\N
20059	00000000-0000-0000-0000-000000000003	d289b33b-0461-4110-9cbf-a3858c2ffe23	6	avoid	\N
20060	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	6	help	\N
20061	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	6	help	\N
20062	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	6	help	\N
20063	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	6	avoid	\N
20064	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	6	avoid	\N
20065	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	6	avoid	\N
20066	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	6	avoid	\N
20067	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	6	help	\N
20068	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	6	help	\N
20069	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	6	help	\N
20070	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	6	help	\N
20071	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	6	feasible	\N
20072	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	6	feasible	\N
20073	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	6	feasible	\N
20074	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	6	feasible	\N
20075	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	6	feasible	\N
20076	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	6	feasible	\N
20077	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	6	feasible	\N
20078	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	6	feasible	\N
20079	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	6	feasible	\N
20080	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	6	feasible	\N
20081	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	6	feasible	\N
20082	00000000-0000-0000-0000-000000000003	ebfc1eca-0430-415c-b6d6-1ebaafed3b03	6	feasible	\N
20083	00000000-0000-0000-0000-000000000003	6587c963-aa20-4f51-835d-61ab0150c4c8	6	help	\N
20084	00000000-0000-0000-0000-000000000003	a6bfa460-c021-44ef-9e5a-f9f76f33bd75	6	help	\N
20085	00000000-0000-0000-0000-000000000003	91bb965a-9e68-4bf0-a1c5-9adf48341abc	6	help	\N
20086	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	7	feasible	\N
20087	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	7	feasible	\N
20088	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	7	feasible	\N
20089	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	7	feasible	\N
20090	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	7	feasible	\N
20091	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	7	feasible	\N
20092	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	7	feasible	\N
20093	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	7	feasible	\N
20094	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	7	feasible	\N
20095	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	7	feasible	\N
20096	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	7	feasible	\N
20097	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	7	feasible	\N
20098	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	7	feasible	\N
20099	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	7	feasible	\N
20100	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	7	feasible	\N
20101	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	7	feasible	\N
20102	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	7	feasible	\N
20103	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	7	feasible	\N
20104	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	7	feasible	\N
20105	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	7	feasible	\N
20106	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	7	feasible	\N
20107	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	7	feasible	\N
20108	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	7	feasible	\N
20109	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	7	feasible	\N
20110	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	7	feasible	\N
20111	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	7	feasible	\N
20112	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	7	feasible	\N
20113	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	7	feasible	\N
20114	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	7	feasible	\N
20115	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	7	feasible	\N
20116	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	7	feasible	\N
20117	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	7	feasible	\N
20118	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	7	feasible	\N
20119	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	7	feasible	\N
20120	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	7	feasible	\N
20121	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	7	feasible	\N
20122	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	7	feasible	\N
20123	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	7	feasible	\N
20124	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	7	feasible	\N
20125	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	7	feasible	\N
20126	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	7	feasible	\N
20127	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	7	feasible	\N
20128	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	7	feasible	\N
20129	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	7	feasible	\N
20130	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	7	feasible	\N
20131	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	7	feasible	\N
20132	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	7	feasible	\N
20133	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	7	feasible	\N
20134	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	7	feasible	\N
20135	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	7	feasible	\N
20136	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	7	feasible	\N
20137	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	7	feasible	\N
20138	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	7	feasible	\N
20139	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	7	feasible	\N
20140	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	7	feasible	\N
20141	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	7	feasible	\N
20142	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	7	feasible	\N
20143	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	7	feasible	\N
20144	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	7	feasible	\N
20145	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	7	feasible	\N
20146	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	7	feasible	\N
20147	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	7	feasible	\N
20148	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	7	feasible	\N
20149	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	7	feasible	\N
20150	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	7	feasible	\N
20151	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	7	feasible	\N
20152	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	7	feasible	\N
20153	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	7	feasible	\N
20154	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	7	feasible	\N
20155	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	7	feasible	\N
20156	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	7	feasible	\N
20157	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	7	feasible	\N
20158	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	7	feasible	\N
20159	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	7	feasible	\N
20160	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	7	feasible	\N
20161	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	7	feasible	\N
20162	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	7	feasible	\N
20163	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	7	feasible	\N
20164	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	7	feasible	\N
20165	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	7	feasible	\N
20166	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	7	feasible	\N
20167	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	7	feasible	\N
20168	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	7	feasible	\N
20169	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	7	feasible	\N
20170	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	7	feasible	\N
20171	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	7	feasible	\N
20172	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	7	feasible	\N
20173	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	7	feasible	\N
20174	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	7	feasible	\N
20175	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	7	feasible	\N
20176	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	7	feasible	\N
20177	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	7	feasible	\N
20178	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	7	feasible	\N
20179	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	7	feasible	\N
20180	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	7	feasible	\N
20181	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	7	feasible	\N
20182	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	7	feasible	\N
20183	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	7	feasible	\N
20184	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	7	feasible	\N
20185	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	7	feasible	\N
20186	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	7	feasible	\N
20187	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	7	feasible	\N
20188	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	7	feasible	\N
20189	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	7	feasible	\N
20190	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	7	feasible	\N
20191	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	7	feasible	\N
20192	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	7	feasible	\N
20193	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	7	feasible	\N
20194	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	7	feasible	\N
20195	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	7	feasible	\N
20196	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	7	feasible	\N
20197	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	7	feasible	\N
20198	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	7	feasible	\N
20199	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	7	feasible	\N
20200	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	7	feasible	\N
20201	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	7	feasible	\N
20202	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	7	feasible	\N
20203	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	7	feasible	\N
20204	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	7	feasible	\N
20205	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	7	feasible	\N
20206	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	7	feasible	\N
20207	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	7	feasible	\N
20208	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	7	feasible	\N
20209	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	7	feasible	\N
20210	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	7	feasible	\N
20211	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	7	feasible	\N
20212	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	7	feasible	\N
20213	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	7	feasible	\N
20214	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	7	feasible	\N
20215	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	7	feasible	\N
20216	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	7	feasible	\N
20217	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	7	feasible	\N
20218	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	7	feasible	\N
20219	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	7	feasible	\N
20220	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	7	feasible	\N
20221	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	7	feasible	\N
20222	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	7	feasible	\N
20223	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	7	feasible	\N
20224	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	7	feasible	\N
20225	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	7	feasible	\N
20226	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	7	feasible	\N
20227	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	7	feasible	\N
20228	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	7	feasible	\N
20229	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	7	feasible	\N
20230	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	7	feasible	\N
20231	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	7	feasible	\N
20232	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	7	feasible	\N
20233	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	7	feasible	\N
20234	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	7	feasible	\N
20235	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	7	feasible	\N
20236	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	7	feasible	\N
20237	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	7	feasible	\N
20238	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	7	feasible	\N
20239	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	7	feasible	\N
20240	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	7	feasible	\N
20241	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	7	feasible	\N
20242	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	7	feasible	\N
20243	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	7	feasible	\N
20244	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	7	feasible	\N
20245	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	7	feasible	\N
20246	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	8	feasible	\N
20247	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	8	feasible	\N
20248	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	8	feasible	\N
20249	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	8	feasible	\N
20250	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	8	feasible	\N
20251	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	8	feasible	\N
20252	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	8	feasible	\N
20253	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	8	feasible	\N
20254	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	8	feasible	\N
20255	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	8	feasible	\N
20256	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	8	feasible	\N
20257	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	8	feasible	\N
20258	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	8	feasible	\N
20259	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	8	feasible	\N
20260	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	8	feasible	\N
20261	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	8	feasible	\N
20262	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	8	feasible	\N
20263	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	8	feasible	\N
20264	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	8	feasible	\N
20265	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	8	feasible	\N
20266	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	8	feasible	\N
20267	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	8	feasible	\N
20268	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	8	feasible	\N
20269	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	8	feasible	\N
20270	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	8	feasible	\N
20271	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	8	feasible	\N
20272	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	8	feasible	\N
20273	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	8	feasible	\N
20274	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	8	feasible	\N
20275	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	8	feasible	\N
20276	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	8	feasible	\N
20277	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	8	feasible	\N
20278	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	8	feasible	\N
20279	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	8	feasible	\N
20280	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	8	feasible	\N
20281	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	8	feasible	\N
20282	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	8	feasible	\N
20283	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	8	feasible	\N
20284	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	8	feasible	\N
20285	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	8	feasible	\N
20286	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	8	feasible	\N
20287	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	8	feasible	\N
20288	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	8	feasible	\N
20289	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	8	feasible	\N
20290	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	8	feasible	\N
20291	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	8	feasible	\N
20292	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	8	feasible	\N
20293	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	8	feasible	\N
20294	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	8	feasible	\N
20295	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	8	feasible	\N
20296	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	8	feasible	\N
20297	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	8	feasible	\N
20298	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	8	feasible	\N
20299	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	8	feasible	\N
20300	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	8	feasible	\N
20301	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	8	feasible	\N
20302	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	8	feasible	\N
20303	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	8	feasible	\N
20304	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	8	feasible	\N
20305	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	8	feasible	\N
20306	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	8	feasible	\N
20307	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	8	feasible	\N
20308	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	8	feasible	\N
20309	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	8	feasible	\N
20310	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	8	feasible	\N
20311	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	8	feasible	\N
20312	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	8	feasible	\N
20313	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	8	feasible	\N
20314	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	8	feasible	\N
20315	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	8	feasible	\N
20316	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	8	feasible	\N
20317	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	8	feasible	\N
20318	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	8	feasible	\N
20319	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	8	feasible	\N
20320	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	8	feasible	\N
20321	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	8	feasible	\N
20322	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	8	feasible	\N
20323	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	8	feasible	\N
20324	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	8	feasible	\N
20325	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	8	feasible	\N
20326	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	8	feasible	\N
20327	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	8	feasible	\N
20328	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	8	feasible	\N
20329	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	8	feasible	\N
20330	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	8	feasible	\N
20331	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	8	feasible	\N
20332	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	8	feasible	\N
20333	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	8	feasible	\N
20334	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	8	feasible	\N
20335	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	8	feasible	\N
20336	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	8	feasible	\N
20337	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	8	feasible	\N
20338	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	8	feasible	\N
20339	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	8	feasible	\N
20340	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	8	feasible	\N
20341	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	8	feasible	\N
20342	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	8	feasible	\N
20343	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	8	feasible	\N
20344	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	8	feasible	\N
20345	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	8	feasible	\N
20346	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	8	feasible	\N
20347	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	8	feasible	\N
20348	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	8	feasible	\N
20349	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	8	feasible	\N
20350	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	8	feasible	\N
20351	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	8	feasible	\N
20352	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	8	feasible	\N
20353	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	8	feasible	\N
20354	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	8	feasible	\N
20355	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	8	feasible	\N
20356	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	8	feasible	\N
20357	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	8	feasible	\N
20358	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	8	feasible	\N
20359	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	8	feasible	\N
20360	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	8	feasible	\N
20361	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	8	feasible	\N
20362	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	8	feasible	\N
20363	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	8	feasible	\N
20364	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	8	feasible	\N
20365	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	8	feasible	\N
20366	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	8	feasible	\N
20367	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	8	feasible	\N
20368	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	8	feasible	\N
20369	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	8	feasible	\N
20370	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	8	feasible	\N
20371	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	8	feasible	\N
20372	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	8	feasible	\N
20373	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	8	feasible	\N
20374	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	8	feasible	\N
20375	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	8	feasible	\N
20376	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	8	feasible	\N
20377	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	8	feasible	\N
20378	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	8	feasible	\N
20379	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	8	feasible	\N
20380	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	8	feasible	\N
20381	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	8	feasible	\N
20382	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	8	feasible	\N
20383	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	8	feasible	\N
20384	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	8	feasible	\N
20385	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	8	feasible	\N
20386	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	8	feasible	\N
20387	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	8	feasible	\N
20388	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	8	feasible	\N
20389	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	8	feasible	\N
20390	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	8	feasible	\N
20391	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	8	feasible	\N
20392	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	8	feasible	\N
20393	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	8	feasible	\N
20394	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	8	feasible	\N
20395	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	8	feasible	\N
20396	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	8	feasible	\N
20397	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	8	feasible	\N
20398	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	8	feasible	\N
20399	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	8	feasible	\N
20400	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	8	feasible	\N
20401	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	8	feasible	\N
20402	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	8	feasible	\N
20403	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	8	feasible	\N
20404	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	8	feasible	\N
20405	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	8	feasible	\N
20406	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	9	feasible	\N
20407	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	9	feasible	\N
20408	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	9	feasible	\N
20409	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	9	feasible	\N
20410	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	9	feasible	\N
20411	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	9	feasible	\N
20412	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	9	feasible	\N
20413	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	9	feasible	\N
20414	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	9	feasible	\N
20415	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	9	feasible	\N
20416	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	9	feasible	\N
20417	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	9	feasible	\N
20418	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	9	feasible	\N
20419	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	9	feasible	\N
20420	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	9	feasible	\N
20421	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	9	feasible	\N
20422	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	9	feasible	\N
20423	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	9	feasible	\N
20424	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	9	feasible	\N
20425	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	9	feasible	\N
20426	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	9	feasible	\N
20427	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	9	feasible	\N
20428	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	9	feasible	\N
20429	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	9	feasible	\N
20430	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	9	feasible	\N
20431	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	9	feasible	\N
20432	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	9	feasible	\N
20433	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	9	feasible	\N
20434	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	9	feasible	\N
20435	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	9	feasible	\N
20436	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	9	feasible	\N
20437	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	9	feasible	\N
20438	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	9	feasible	\N
20439	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	9	feasible	\N
20440	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	9	feasible	\N
20441	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	9	feasible	\N
20442	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	9	feasible	\N
20443	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	9	feasible	\N
20444	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	9	feasible	\N
20445	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	9	feasible	\N
20446	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	9	feasible	\N
20447	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	9	feasible	\N
20448	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	9	feasible	\N
20449	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	9	feasible	\N
20450	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	9	feasible	\N
20451	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	9	feasible	\N
20452	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	9	feasible	\N
20453	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	9	feasible	\N
20454	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	9	feasible	\N
20455	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	9	feasible	\N
20456	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	9	feasible	\N
20457	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	9	feasible	\N
20458	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	9	feasible	\N
20459	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	9	feasible	\N
20460	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	9	feasible	\N
20461	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	9	feasible	\N
20462	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	9	feasible	\N
20463	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	9	feasible	\N
20464	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	9	feasible	\N
20465	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	9	feasible	\N
20466	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	9	feasible	\N
20467	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	9	feasible	\N
20468	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	9	feasible	\N
20469	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	9	feasible	\N
20470	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	9	feasible	\N
20471	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	9	feasible	\N
20472	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	9	feasible	\N
20473	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	9	feasible	\N
20474	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	9	feasible	\N
20475	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	9	feasible	\N
20476	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	9	feasible	\N
20477	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	9	feasible	\N
20478	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	9	feasible	\N
20479	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	9	feasible	\N
20480	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	9	feasible	\N
20481	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	9	feasible	\N
20482	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	9	feasible	\N
20483	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	9	feasible	\N
20484	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	9	feasible	\N
20485	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	9	feasible	\N
20486	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	9	feasible	\N
20487	00000000-0000-0000-0000-000000000003	a7553185-1ae9-4cd6-bcdc-ebf1e268b12b	9	feasible	\N
20488	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	9	feasible	\N
20489	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	9	feasible	\N
20490	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	9	feasible	\N
20491	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	9	feasible	\N
20492	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	9	feasible	\N
20493	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	9	feasible	\N
20494	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	9	feasible	\N
20495	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	9	feasible	\N
20496	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	9	feasible	\N
20497	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	9	feasible	\N
20498	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	9	feasible	\N
20499	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	9	feasible	\N
20500	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	9	feasible	\N
20501	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	9	feasible	\N
20502	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	9	feasible	\N
20503	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	9	feasible	\N
20504	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	9	feasible	\N
20505	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	9	feasible	\N
20506	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	9	feasible	\N
20507	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	9	feasible	\N
20508	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	9	feasible	\N
20509	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	9	feasible	\N
20510	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	9	feasible	\N
20511	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	9	feasible	\N
20512	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	9	feasible	\N
20513	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	9	feasible	\N
20514	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	9	feasible	\N
20515	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	9	feasible	\N
20516	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	9	feasible	\N
20517	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	9	feasible	\N
20518	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	9	feasible	\N
20519	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	9	feasible	\N
20520	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	9	feasible	\N
20521	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	9	feasible	\N
20522	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	9	feasible	\N
20523	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	9	feasible	\N
20524	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	9	feasible	\N
20525	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	9	feasible	\N
20526	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	9	feasible	\N
20527	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	9	feasible	\N
20528	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	9	feasible	\N
20529	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	9	feasible	\N
20530	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	9	feasible	\N
20531	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	9	feasible	\N
20532	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	9	feasible	\N
20533	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	9	feasible	\N
20534	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	9	feasible	\N
20535	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	9	feasible	\N
20536	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	9	feasible	\N
20537	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	9	feasible	\N
20538	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	9	feasible	\N
20539	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	9	feasible	\N
20540	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	9	feasible	\N
20541	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	9	feasible	\N
20542	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	9	feasible	\N
20543	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	9	feasible	\N
20544	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	9	feasible	\N
20545	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	9	feasible	\N
20546	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	9	feasible	\N
20547	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	9	feasible	\N
20548	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	9	feasible	\N
20549	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	9	feasible	\N
20550	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	9	feasible	\N
20551	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	9	feasible	\N
20552	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	9	feasible	\N
20553	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	9	feasible	\N
20554	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	9	feasible	\N
20555	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	9	feasible	\N
20556	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	9	feasible	\N
20557	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	9	feasible	\N
20558	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	9	feasible	\N
20559	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	9	feasible	\N
20560	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	9	feasible	\N
20561	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	9	feasible	\N
20562	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	9	feasible	\N
20563	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	9	feasible	\N
20564	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	9	feasible	\N
20565	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	9	feasible	\N
20566	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	10	feasible	\N
20567	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	10	feasible	\N
20568	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	10	feasible	\N
20569	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	10	feasible	\N
20570	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	10	feasible	\N
20571	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	10	feasible	\N
20572	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	10	feasible	\N
20573	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	10	feasible	\N
20574	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	10	feasible	\N
20575	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	10	feasible	\N
20576	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	10	feasible	\N
20577	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	10	feasible	\N
20578	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	10	feasible	\N
20579	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	10	feasible	\N
20580	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	10	feasible	\N
20581	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	10	feasible	\N
20582	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	10	feasible	\N
20583	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	10	feasible	\N
20584	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	10	feasible	\N
20585	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	10	feasible	\N
20586	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	10	feasible	\N
20587	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	10	feasible	\N
20588	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	10	feasible	\N
20589	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	10	feasible	\N
20590	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	10	feasible	\N
20591	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	10	feasible	\N
20592	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	10	feasible	\N
20593	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	10	feasible	\N
20594	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	10	feasible	\N
20595	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	10	feasible	\N
20596	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	10	feasible	\N
20597	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	10	feasible	\N
20598	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	10	feasible	\N
20599	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	10	feasible	\N
20600	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	10	feasible	\N
20601	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	10	feasible	\N
20602	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	10	feasible	\N
20603	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	10	feasible	\N
20604	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	10	feasible	\N
20605	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	10	feasible	\N
20606	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	10	feasible	\N
20607	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	10	feasible	\N
20608	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	10	feasible	\N
20609	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	10	feasible	\N
20610	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	10	feasible	\N
20611	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	10	feasible	\N
20612	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	10	feasible	\N
20613	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	10	feasible	\N
20614	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	10	feasible	\N
20615	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	10	feasible	\N
20616	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	10	feasible	\N
20617	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	10	feasible	\N
20618	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	10	feasible	\N
20619	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	10	feasible	\N
20620	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	10	feasible	\N
20621	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	10	feasible	\N
20622	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	10	feasible	\N
20623	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	10	feasible	\N
20624	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	10	feasible	\N
20625	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	10	feasible	\N
20626	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	10	feasible	\N
20627	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	10	feasible	\N
20628	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	10	feasible	\N
20629	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	10	feasible	\N
20630	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	10	feasible	\N
20631	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	10	feasible	\N
20632	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	10	feasible	\N
20633	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	10	feasible	\N
20634	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	10	feasible	\N
20635	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	10	feasible	\N
20636	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	10	feasible	\N
20637	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	10	feasible	\N
20638	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	10	feasible	\N
20639	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	10	feasible	\N
20640	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	10	feasible	\N
20641	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	10	feasible	\N
20642	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	10	feasible	\N
20643	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	10	feasible	\N
20644	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	10	feasible	\N
20645	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	10	feasible	\N
20646	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	10	feasible	\N
20647	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	10	feasible	\N
20648	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	10	feasible	\N
20649	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	10	feasible	\N
20650	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	10	feasible	\N
20651	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	10	feasible	\N
20652	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	10	feasible	\N
20653	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	10	feasible	\N
20654	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	10	feasible	\N
20655	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	10	feasible	\N
20656	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	10	feasible	\N
20657	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	10	feasible	\N
20658	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	10	feasible	\N
20659	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	10	feasible	\N
20660	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	10	feasible	\N
20661	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	10	feasible	\N
20662	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	10	feasible	\N
20663	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	10	feasible	\N
20664	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	10	feasible	\N
20665	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	10	feasible	\N
20666	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	10	feasible	\N
20667	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	10	feasible	\N
20668	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	10	feasible	\N
20669	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	10	feasible	\N
20670	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	10	feasible	\N
20671	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	10	feasible	\N
20672	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	10	feasible	\N
20673	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	10	feasible	\N
20674	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	10	feasible	\N
20675	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	10	feasible	\N
20676	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	10	feasible	\N
20677	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	10	feasible	\N
20678	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	10	feasible	\N
20679	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	10	feasible	\N
20680	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	10	feasible	\N
20681	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	10	feasible	\N
20682	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	10	feasible	\N
20683	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	10	feasible	\N
20684	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	10	feasible	\N
20685	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	10	feasible	\N
20686	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	10	feasible	\N
20687	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	10	feasible	\N
20688	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	10	feasible	\N
20689	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	10	feasible	\N
20690	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	10	feasible	\N
20691	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	10	feasible	\N
20692	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	10	feasible	\N
20693	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	10	feasible	\N
20694	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	10	feasible	\N
20695	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	10	feasible	\N
20696	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	10	feasible	\N
20697	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	10	feasible	\N
20698	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	10	feasible	\N
20699	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	10	feasible	\N
20700	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	10	feasible	\N
20701	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	10	feasible	\N
20702	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	10	feasible	\N
20703	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	10	feasible	\N
20704	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	10	feasible	\N
20705	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	10	feasible	\N
20706	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	10	feasible	\N
20707	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	10	feasible	\N
20708	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	10	feasible	\N
20709	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	10	feasible	\N
20710	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	10	feasible	\N
20711	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	10	feasible	\N
20712	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	10	feasible	\N
20713	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	10	feasible	\N
20714	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	10	feasible	\N
20715	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	10	feasible	\N
20716	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	10	feasible	\N
20717	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	10	feasible	\N
20718	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	10	feasible	\N
20719	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	10	feasible	\N
20720	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	10	feasible	\N
20721	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	10	feasible	\N
20722	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	10	feasible	\N
20723	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	10	feasible	\N
20724	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	10	feasible	\N
20725	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	10	feasible	\N
20726	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	11	feasible	\N
20727	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	11	feasible	\N
20728	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	11	feasible	\N
20729	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	11	feasible	\N
20730	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	11	feasible	\N
20731	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	11	feasible	\N
20732	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	11	feasible	\N
20733	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	11	feasible	\N
20734	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	11	feasible	\N
20735	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	11	feasible	\N
20736	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	11	feasible	\N
20737	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	11	feasible	\N
20738	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	11	feasible	\N
20739	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	11	feasible	\N
20740	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	11	feasible	\N
20741	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	11	feasible	\N
20742	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	11	feasible	\N
20743	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	11	feasible	\N
20744	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	11	feasible	\N
20745	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	11	feasible	\N
20746	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	11	feasible	\N
20747	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	11	feasible	\N
20748	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	11	feasible	\N
20749	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	11	feasible	\N
20750	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	11	feasible	\N
20751	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	11	feasible	\N
20752	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	11	feasible	\N
20753	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	11	feasible	\N
20754	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	11	feasible	\N
20755	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	11	feasible	\N
20756	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	11	feasible	\N
20757	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	11	feasible	\N
20758	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	11	feasible	\N
20759	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	11	feasible	\N
20760	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	11	feasible	\N
20761	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	11	feasible	\N
20762	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	11	feasible	\N
20763	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	11	feasible	\N
20764	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	11	feasible	\N
20765	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	11	feasible	\N
20766	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	11	feasible	\N
20767	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	11	feasible	\N
20768	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	11	feasible	\N
20769	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	11	feasible	\N
20770	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	11	feasible	\N
20771	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	11	feasible	\N
20772	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	11	feasible	\N
20773	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	11	feasible	\N
20774	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	11	feasible	\N
20775	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	11	feasible	\N
20776	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	11	feasible	\N
20777	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	11	feasible	\N
20778	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	11	feasible	\N
20779	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	11	feasible	\N
20780	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	11	feasible	\N
20781	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	11	feasible	\N
20782	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	11	feasible	\N
20783	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	11	feasible	\N
20784	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	11	feasible	\N
20785	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	11	feasible	\N
20786	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	11	feasible	\N
20787	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	11	feasible	\N
20788	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	11	feasible	\N
20789	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	11	feasible	\N
20790	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	11	feasible	\N
20791	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	11	feasible	\N
20792	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	11	feasible	\N
20793	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	11	feasible	\N
20794	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	11	feasible	\N
20795	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	11	feasible	\N
20796	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	11	feasible	\N
20797	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	11	feasible	\N
20798	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	11	feasible	\N
20799	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	11	feasible	\N
20800	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	11	feasible	\N
20801	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	11	feasible	\N
20802	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	11	feasible	\N
20803	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	11	feasible	\N
20804	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	11	feasible	\N
20805	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	11	feasible	\N
20806	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	11	feasible	\N
20807	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	11	feasible	\N
20808	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	11	feasible	\N
20809	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	11	feasible	\N
20810	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	11	feasible	\N
20811	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	11	feasible	\N
20812	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	11	feasible	\N
20813	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	11	feasible	\N
20814	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	11	feasible	\N
20815	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	11	feasible	\N
20816	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	11	feasible	\N
20817	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	11	feasible	\N
20818	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	11	feasible	\N
20819	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	11	feasible	\N
20820	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	11	feasible	\N
20821	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	11	feasible	\N
20822	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	11	feasible	\N
20823	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	11	feasible	\N
20824	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	11	feasible	\N
20825	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	11	feasible	\N
20826	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	11	feasible	\N
20827	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	11	feasible	\N
20828	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	11	feasible	\N
20829	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	11	feasible	\N
20830	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	11	feasible	\N
20831	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	11	feasible	\N
20832	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	11	feasible	\N
20833	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	11	feasible	\N
20834	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	11	feasible	\N
20835	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	11	feasible	\N
20836	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	11	feasible	\N
20837	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	11	feasible	\N
20838	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	11	feasible	\N
20839	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	11	feasible	\N
20840	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	11	feasible	\N
20841	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	11	feasible	\N
20842	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	11	feasible	\N
20843	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	11	feasible	\N
20844	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	11	feasible	\N
20845	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	11	feasible	\N
20846	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	11	feasible	\N
20847	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	11	feasible	\N
20848	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	11	feasible	\N
20849	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	11	feasible	\N
20850	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	11	feasible	\N
20851	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	11	feasible	\N
20852	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	11	feasible	\N
20853	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	11	feasible	\N
20854	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	11	feasible	\N
20855	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	11	feasible	\N
20856	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	11	feasible	\N
20857	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	11	feasible	\N
20858	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	11	feasible	\N
20859	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	11	feasible	\N
20860	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	11	feasible	\N
20861	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	11	feasible	\N
20862	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	11	feasible	\N
20863	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	11	feasible	\N
20864	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	11	feasible	\N
20865	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	11	feasible	\N
20866	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	11	feasible	\N
20867	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	11	feasible	\N
20868	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	11	feasible	\N
20869	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	11	feasible	\N
20870	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	11	feasible	\N
20871	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	11	feasible	\N
20872	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	11	feasible	\N
20873	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	11	feasible	\N
20874	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	11	feasible	\N
20875	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	11	feasible	\N
20876	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	11	feasible	\N
20877	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	11	feasible	\N
20878	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	11	feasible	\N
20879	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	11	feasible	\N
20880	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	11	feasible	\N
20881	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	11	feasible	\N
20882	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	11	feasible	\N
20883	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	11	feasible	\N
20884	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	11	feasible	\N
20885	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	11	feasible	\N
20886	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	12	feasible	\N
20887	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	12	feasible	\N
20888	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	12	feasible	\N
20889	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	12	feasible	\N
20890	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	12	feasible	\N
20891	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	12	feasible	\N
20892	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	12	feasible	\N
20893	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	12	feasible	\N
20894	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	12	feasible	\N
20895	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	12	feasible	\N
20896	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	12	feasible	\N
20897	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	12	feasible	\N
20898	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	12	feasible	\N
20899	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	12	feasible	\N
20900	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	12	feasible	\N
20901	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	12	feasible	\N
20902	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	12	feasible	\N
20903	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	12	feasible	\N
20904	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	12	feasible	\N
20905	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	12	feasible	\N
20906	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	12	feasible	\N
20907	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	12	feasible	\N
20908	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	12	feasible	\N
20909	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	12	feasible	\N
20910	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	12	feasible	\N
20911	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	12	feasible	\N
20912	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	12	feasible	\N
20913	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	12	feasible	\N
20914	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	12	feasible	\N
20915	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	12	feasible	\N
20916	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	12	feasible	\N
20917	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	12	feasible	\N
20918	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	12	feasible	\N
20919	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	12	feasible	\N
20920	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	12	feasible	\N
20921	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	12	feasible	\N
20922	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	12	feasible	\N
20923	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	12	feasible	\N
20924	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	12	feasible	\N
20925	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	12	feasible	\N
20926	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	12	feasible	\N
20927	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	12	feasible	\N
20928	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	12	feasible	\N
20929	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	12	feasible	\N
20930	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	12	feasible	\N
20931	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	12	feasible	\N
20932	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	12	feasible	\N
20933	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	12	feasible	\N
20934	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	12	feasible	\N
20935	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	12	feasible	\N
20936	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	12	feasible	\N
20937	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	12	feasible	\N
20938	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	12	feasible	\N
20939	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	12	feasible	\N
20940	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	12	feasible	\N
20941	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	12	feasible	\N
20942	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	12	feasible	\N
20943	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	12	feasible	\N
20944	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	12	feasible	\N
20945	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	12	feasible	\N
20946	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	12	feasible	\N
20947	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	12	feasible	\N
20948	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	12	feasible	\N
20949	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	12	feasible	\N
20950	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	12	feasible	\N
20951	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	12	feasible	\N
20952	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	12	feasible	\N
20953	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	12	feasible	\N
20954	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	12	feasible	\N
20955	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	12	feasible	\N
20956	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	12	feasible	\N
20957	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	12	feasible	\N
20958	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	12	feasible	\N
20959	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	12	feasible	\N
20960	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	12	feasible	\N
20961	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	12	feasible	\N
20962	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	12	feasible	\N
20963	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	12	feasible	\N
20964	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	12	feasible	\N
20965	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	12	feasible	\N
20966	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	12	feasible	\N
20967	00000000-0000-0000-0000-000000000003	6364510d-2ecb-42e9-8f47-e1c816190b48	12	feasible	\N
20968	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	12	feasible	\N
20969	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	12	feasible	\N
20970	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	12	feasible	\N
20971	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	12	feasible	\N
20972	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	12	feasible	\N
20973	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	12	feasible	\N
20974	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	12	feasible	\N
20975	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	12	feasible	\N
20976	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	12	feasible	\N
20977	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	12	feasible	\N
20978	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	12	feasible	\N
20979	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	12	feasible	\N
20980	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	12	feasible	\N
20981	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	12	feasible	\N
20982	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	12	feasible	\N
20983	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	12	feasible	\N
20984	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	12	feasible	\N
20985	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	12	feasible	\N
20986	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	12	feasible	\N
20987	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	12	feasible	\N
20988	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	12	feasible	\N
20989	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	12	feasible	\N
20990	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	12	feasible	\N
20991	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	12	feasible	\N
20992	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	12	feasible	\N
20993	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	12	feasible	\N
20994	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	12	feasible	\N
20995	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	12	feasible	\N
20996	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	12	feasible	\N
20997	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	12	feasible	\N
20998	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	12	feasible	\N
20999	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	12	feasible	\N
21000	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	12	feasible	\N
21001	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	12	feasible	\N
21002	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	12	feasible	\N
21003	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	12	feasible	\N
21004	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	12	feasible	\N
21005	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	12	feasible	\N
21006	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	12	feasible	\N
21007	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	12	feasible	\N
21008	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	12	feasible	\N
21009	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	12	feasible	\N
21010	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	12	feasible	\N
21011	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	12	feasible	\N
21012	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	12	feasible	\N
21013	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	12	feasible	\N
21014	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	12	feasible	\N
21015	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	12	feasible	\N
21016	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	12	feasible	\N
21017	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	12	feasible	\N
21018	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	12	feasible	\N
21019	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	12	feasible	\N
21020	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	12	feasible	\N
21021	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	12	feasible	\N
21022	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	12	feasible	\N
21023	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	12	feasible	\N
21024	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	12	feasible	\N
21025	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	12	feasible	\N
21026	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	12	feasible	\N
21027	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	12	feasible	\N
21028	00000000-0000-0000-0000-000000000003	f96f99b3-cbd5-4407-b259-c97b7fcd2799	12	feasible	\N
21029	00000000-0000-0000-0000-000000000003	0f2a2d12-a256-4c5d-9fa2-6fde68248472	12	feasible	\N
21030	00000000-0000-0000-0000-000000000003	c5c68247-5894-4ee5-9de5-070063da6cc0	12	feasible	\N
21031	00000000-0000-0000-0000-000000000003	83cb2556-bdc6-400d-8257-edc1750e7a4a	12	feasible	\N
21032	00000000-0000-0000-0000-000000000003	36f9135b-0499-4288-b052-c5a1e297f6ed	12	feasible	\N
21033	00000000-0000-0000-0000-000000000003	9190503c-fb9d-4a0f-8cce-05ad78160420	12	feasible	\N
21034	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	12	feasible	\N
21035	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	12	feasible	\N
21036	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	12	feasible	\N
21037	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	12	feasible	\N
21038	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	12	feasible	\N
21039	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	12	feasible	\N
21040	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	12	feasible	\N
21041	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	12	feasible	\N
21042	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	12	feasible	\N
21043	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	12	feasible	\N
21044	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	12	feasible	\N
21045	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	12	feasible	\N
21046	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	13	feasible	\N
21047	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	13	feasible	\N
21048	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	13	feasible	\N
21049	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	13	feasible	\N
21050	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	13	feasible	\N
21051	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	13	help	\N
21052	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	13	feasible	\N
21053	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	13	feasible	\N
21054	00000000-0000-0000-0000-000000000003	f0704eb5-98f1-4972-b242-94f0ad6f3bba	13	feasible	\N
21055	00000000-0000-0000-0000-000000000003	fe79fe8d-1b76-4546-9ef5-2341c40a516f	13	feasible	\N
21056	00000000-0000-0000-0000-000000000003	518b0620-03d6-4115-b57b-523d50dd3744	13	feasible	\N
21057	00000000-0000-0000-0000-000000000003	619dbf9e-5ebd-43e6-b796-63e7db4037f3	13	feasible	\N
21058	00000000-0000-0000-0000-000000000003	e584e84c-e8ba-40ea-8fa9-b2526e1f4d7b	13	feasible	\N
21059	00000000-0000-0000-0000-000000000003	194a9f58-ebf8-48d1-9dc3-69a866e9cf55	13	feasible	\N
21060	00000000-0000-0000-0000-000000000003	f5be434f-16cb-47f4-ae0e-b6cc67815b30	13	help	\N
21061	00000000-0000-0000-0000-000000000003	646aca0b-564f-4410-a6b6-383dfb3b8f12	13	feasible	\N
21062	00000000-0000-0000-0000-000000000003	9deb40f9-cb4b-43bd-9c6c-68b6f1b33744	13	feasible	\N
21063	00000000-0000-0000-0000-000000000003	531543ca-7a31-423c-b84b-4fdf5fc6e1ef	13	feasible	\N
21064	00000000-0000-0000-0000-000000000003	dfdb8220-bf81-4970-b92d-276a46f30f2a	13	feasible	\N
21065	00000000-0000-0000-0000-000000000003	373edbec-cf27-44c6-bdb5-760fac3c4d95	13	feasible	\N
21066	00000000-0000-0000-0000-000000000003	a5f29a8a-84d3-4a17-b3f9-83ad88f7aacb	13	feasible	\N
21067	00000000-0000-0000-0000-000000000003	1147d0ac-cf56-4af2-a1a6-e22c1b6924a4	13	feasible	\N
21068	00000000-0000-0000-0000-000000000003	90a9f83d-59c4-473c-b847-d1b92e8fd894	13	feasible	\N
21069	00000000-0000-0000-0000-000000000003	e1c9ffd7-1605-45c1-9dd4-5c61b7105f68	13	feasible	\N
21070	00000000-0000-0000-0000-000000000003	980fcaa8-4dce-4353-83bc-b4e387fa0de9	13	feasible	\N
21071	00000000-0000-0000-0000-000000000003	8376d443-d43f-41b3-b038-5b41825d43b6	13	help	\N
21072	00000000-0000-0000-0000-000000000003	71abd243-6b8b-4e8a-b57d-df1416e8bf61	13	feasible	\N
21073	00000000-0000-0000-0000-000000000003	5bd80f6f-c1e7-41b5-8f90-9304cb634e77	13	feasible	\N
21074	00000000-0000-0000-0000-000000000003	00f81c31-e54a-4388-9d99-b2d9019b2a1c	13	feasible	\N
21075	00000000-0000-0000-0000-000000000003	7a281159-aff0-42f2-a00e-577d7c05f1ec	13	feasible	\N
21076	00000000-0000-0000-0000-000000000003	c968f18a-586e-41d6-b75e-910c2f29714a	13	feasible	\N
21077	00000000-0000-0000-0000-000000000003	96d01bf8-a977-4487-91e5-d71ff4454d11	13	feasible	\N
21078	00000000-0000-0000-0000-000000000003	58c62667-b3bd-4cd3-bd0a-dfc92a7c9301	13	feasible	\N
21079	00000000-0000-0000-0000-000000000003	619b1fa6-28e2-42b5-99f1-67c64c3f45bc	13	feasible	\N
21080	00000000-0000-0000-0000-000000000003	d1e4db37-5a24-42ca-95f5-fa1a7645162d	13	feasible	\N
21081	00000000-0000-0000-0000-000000000003	e92e0d31-2ded-40b1-8776-a212c57dd04c	13	feasible	\N
21082	00000000-0000-0000-0000-000000000003	3aa178a2-078f-4a09-afe3-ce3e1dc72afe	13	feasible	\N
21083	00000000-0000-0000-0000-000000000003	adf294e9-ea01-43f5-873e-aba6392d9e61	13	feasible	\N
21084	00000000-0000-0000-0000-000000000003	7ad4b4d3-5958-46c0-b54b-6f81d89cb2ad	13	feasible	\N
21085	00000000-0000-0000-0000-000000000003	6b917be4-1c06-4217-9134-c0d806db42f2	13	feasible	\N
21086	00000000-0000-0000-0000-000000000003	83ef8714-7e52-44cf-9145-e891d058b7e5	13	feasible	\N
21087	00000000-0000-0000-0000-000000000003	ed663b5b-c7f1-4b26-a4ab-2f3c3baa0789	13	help	\N
21088	00000000-0000-0000-0000-000000000003	2d0978ab-9302-46a1-b32f-ec74b7202106	13	feasible	\N
21089	00000000-0000-0000-0000-000000000003	72f80da9-dbec-4bc3-8157-d86ddf3be197	13	feasible	\N
21090	00000000-0000-0000-0000-000000000003	4a73058b-3392-45d7-9fa1-215e412643db	13	feasible	\N
21091	00000000-0000-0000-0000-000000000003	6189465d-1539-4662-ac4c-4ca05895b8ca	13	feasible	\N
21092	00000000-0000-0000-0000-000000000003	1577000b-b1a9-414b-bdd2-4759a3c062a1	13	feasible	\N
21093	00000000-0000-0000-0000-000000000003	d33ca546-f779-448d-9813-cf30925ac543	13	feasible	\N
21094	00000000-0000-0000-0000-000000000003	80089617-1462-4fc2-97d1-3fdc7a1c45c4	13	feasible	\N
21095	00000000-0000-0000-0000-000000000003	bcdb602f-3adc-400d-9c64-4d40679ae63b	13	feasible	\N
21096	00000000-0000-0000-0000-000000000003	3cf3992e-60f2-4775-b398-5c02586f8c73	13	feasible	\N
21097	00000000-0000-0000-0000-000000000003	60d46bc0-f37a-4626-bfd9-a561a92f2d4f	13	feasible	\N
21098	00000000-0000-0000-0000-000000000003	f7f265ac-9ac4-403b-9004-4dc73e6584cc	13	feasible	\N
21099	00000000-0000-0000-0000-000000000003	068c76d5-8134-4b96-9b69-e03911b2b45f	13	feasible	\N
21100	00000000-0000-0000-0000-000000000003	871a4fb6-3029-44ac-b870-2114e7ca36d2	13	feasible	\N
21101	00000000-0000-0000-0000-000000000003	2326c028-3b42-45fe-83c3-f12c82a1170c	13	feasible	\N
21102	00000000-0000-0000-0000-000000000003	67af8f24-d446-4afb-ba6b-e761b31d79b4	13	feasible	\N
21103	00000000-0000-0000-0000-000000000003	80e0ba54-29fa-46bb-8f9a-c565d1195eeb	13	feasible	\N
21104	00000000-0000-0000-0000-000000000003	a3f551b8-b62c-401c-929b-0fdac3e8e175	13	feasible	\N
21105	00000000-0000-0000-0000-000000000003	bad133ff-aa7b-4c17-8e15-18409eb06f7c	13	feasible	\N
21106	00000000-0000-0000-0000-000000000003	84ca4261-45d3-4832-aa50-e7bba0ac355c	13	feasible	\N
21107	00000000-0000-0000-0000-000000000003	21bc8ca8-ff21-488f-9c2d-d99a1e460ebe	13	help	\N
21108	00000000-0000-0000-0000-000000000003	5c87c57f-fe2a-435d-9476-3e5f1f380ebf	13	feasible	\N
21109	00000000-0000-0000-0000-000000000003	b9868415-0ca1-46bf-a698-978593cd03a2	13	feasible	\N
21110	00000000-0000-0000-0000-000000000003	7391b8f7-d9ae-459e-9c97-719cf923700c	13	feasible	\N
21111	00000000-0000-0000-0000-000000000003	4bae7649-4d2c-439c-9d02-6999885aac5f	13	feasible	\N
21112	00000000-0000-0000-0000-000000000003	696179fc-1885-4427-85e6-9946df1a7611	13	feasible	\N
21113	00000000-0000-0000-0000-000000000003	3a0c5a85-2f71-4303-95e6-e46e6f974930	13	feasible	\N
21114	00000000-0000-0000-0000-000000000003	17c1a934-f27b-4db7-8cc7-331501d2bf10	13	feasible	\N
21115	00000000-0000-0000-0000-000000000003	a9d995ce-3ef6-4dbf-aefc-eb7585881516	13	feasible	\N
21116	00000000-0000-0000-0000-000000000003	d85b1a78-d1f6-49cd-a7ee-c0300b95582a	13	feasible	\N
21117	00000000-0000-0000-0000-000000000003	c35c6020-7ce5-42c9-9ae8-775acf4d1c88	13	feasible	\N
21118	00000000-0000-0000-0000-000000000003	3be8c7f5-f80f-4813-b9d1-ffd1e81c982a	13	feasible	\N
21119	00000000-0000-0000-0000-000000000003	1f167592-fce0-48f4-ab06-d8dab118f616	13	feasible	\N
21120	00000000-0000-0000-0000-000000000003	e534d46b-9c5e-4100-9d73-59ab2197469f	13	feasible	\N
21121	00000000-0000-0000-0000-000000000003	92377be7-593b-4340-881f-f7f5047f0ac1	13	feasible	\N
21122	00000000-0000-0000-0000-000000000003	5a408249-c161-4e73-a826-a43496a082f3	13	feasible	\N
21123	00000000-0000-0000-0000-000000000003	619bcd3c-4d6f-4326-af52-3c71438756e0	13	feasible	\N
21124	00000000-0000-0000-0000-000000000003	745bdb91-19b3-42a8-b0a0-2249f4e28f18	13	feasible	\N
21125	00000000-0000-0000-0000-000000000003	5aae7587-5b14-4414-a43e-4dee41801bc8	13	feasible	\N
21126	00000000-0000-0000-0000-000000000003	b551183d-b614-4742-8fd9-1f4fe7e19192	13	feasible	\N
21127	00000000-0000-0000-0000-000000000003	ba76e47b-f38c-401f-8e9a-a3f5be662e77	13	feasible	\N
21128	00000000-0000-0000-0000-000000000003	67031e05-6b12-4cc3-84d0-de9269741a2b	13	feasible	\N
21129	00000000-0000-0000-0000-000000000003	71b0b3eb-a7f7-4cbe-b87e-5133a099ffb4	13	feasible	\N
21130	00000000-0000-0000-0000-000000000003	a45fd087-030b-4a15-bf3f-23e7733e9f0e	13	feasible	\N
21131	00000000-0000-0000-0000-000000000003	b1ffd138-e5d2-4dfd-8a6b-c426058ebbf2	13	feasible	\N
21132	00000000-0000-0000-0000-000000000003	eaf5ec2d-b416-4be2-a3d7-fddca1e784b5	13	feasible	\N
21133	00000000-0000-0000-0000-000000000003	79f7fb10-b0ee-4ed3-bcca-cb12a3b72f8a	13	feasible	\N
21134	00000000-0000-0000-0000-000000000003	65574b1c-61b7-4b41-962d-b17b8dc1d4a5	13	feasible	\N
21135	00000000-0000-0000-0000-000000000003	b40556f8-43a6-4c5a-9f1e-f56740ed9a00	13	feasible	\N
21136	00000000-0000-0000-0000-000000000003	6dad898b-aa62-452d-9674-bfa81b134c7e	13	feasible	\N
21137	00000000-0000-0000-0000-000000000003	94e65ba6-dd74-4513-bed9-b7dedba0eb2e	13	feasible	\N
21138	00000000-0000-0000-0000-000000000003	a66888fe-92c4-4548-ba7d-97db23e2a7f2	13	feasible	\N
21139	00000000-0000-0000-0000-000000000003	24c959f3-18d6-4e46-9d0d-bab21058f2d5	13	feasible	\N
21140	00000000-0000-0000-0000-000000000003	3fd85f2b-97b9-41e9-8850-9ee9f2466918	13	feasible	\N
21141	00000000-0000-0000-0000-000000000003	0d8f0247-efaa-4343-acd6-614d1c9d3971	13	feasible	\N
21142	00000000-0000-0000-0000-000000000003	454ae584-3ade-4d6c-995f-d754726d43b7	13	feasible	\N
21143	00000000-0000-0000-0000-000000000003	a98398d6-4de1-4404-8e73-65ae4000244f	13	feasible	\N
21144	00000000-0000-0000-0000-000000000003	4a4d28c2-8932-4361-a390-4fdb93820712	13	feasible	\N
21145	00000000-0000-0000-0000-000000000003	ecbc5672-cbe8-4a7c-b74e-321239f548c5	13	feasible	\N
21146	00000000-0000-0000-0000-000000000003	180f2539-17f3-4075-912b-4b706b294e72	13	feasible	\N
21147	00000000-0000-0000-0000-000000000003	c047fae8-2d62-4eb0-bc03-ec05cd9310c0	13	feasible	\N
21148	00000000-0000-0000-0000-000000000003	fcfc7205-f0b0-4de6-a256-7625d4c65cd2	13	feasible	\N
21149	00000000-0000-0000-0000-000000000003	b75a23a5-a286-4842-96f6-9abac1de1156	13	help	\N
21150	00000000-0000-0000-0000-000000000003	7903e0fc-aa7d-4b13-b49a-5b6e297c87b5	13	feasible	\N
21151	00000000-0000-0000-0000-000000000003	0666d99d-44b2-4c15-94be-a929a3d8b43e	13	feasible	\N
21152	00000000-0000-0000-0000-000000000003	8b687a8e-eaa3-4e06-a664-b5a6a4447155	13	feasible	\N
21153	00000000-0000-0000-0000-000000000003	79019cce-b13e-425e-86f1-d1c0b226650f	13	feasible	\N
21154	00000000-0000-0000-0000-000000000003	3ade4f3c-d46f-4409-bcf7-d7bcf617de07	13	feasible	\N
21155	00000000-0000-0000-0000-000000000003	19b94cfa-92bc-4c1b-898e-a466270a846c	13	feasible	\N
21156	00000000-0000-0000-0000-000000000003	b3952e94-3bbf-454f-a510-c116a9646fe2	13	feasible	\N
21157	00000000-0000-0000-0000-000000000003	4099170f-0e50-4050-9de5-38529094d8a2	13	feasible	\N
21158	00000000-0000-0000-0000-000000000003	aec6af48-8c68-4417-8ac2-cf4a039db1f0	13	feasible	\N
21159	00000000-0000-0000-0000-000000000003	24d96554-ac13-4cc8-bb2f-092304c678ab	13	feasible	\N
21160	00000000-0000-0000-0000-000000000003	df29d8dd-a4dd-424c-b7b7-cb4b379cdb16	13	feasible	\N
21161	00000000-0000-0000-0000-000000000003	2549ae79-1a34-4a0d-9ea9-c355982de1af	13	feasible	\N
21162	00000000-0000-0000-0000-000000000003	fe081bbf-8016-4e21-8906-2d62a6ae3d6e	13	feasible	\N
21163	00000000-0000-0000-0000-000000000003	9f815a08-5698-47bd-aa23-20d39143539a	13	feasible	\N
21164	00000000-0000-0000-0000-000000000003	0d367c27-1b3a-4c7c-938b-b08d40e538e3	13	feasible	\N
21165	00000000-0000-0000-0000-000000000003	b1bab347-e36d-4531-8c01-706f8ebf0b6d	13	feasible	\N
21166	00000000-0000-0000-0000-000000000003	f7ac92d1-14aa-41a6-bb0d-3dfe107a5c51	13	feasible	\N
21167	00000000-0000-0000-0000-000000000003	d1f2deac-da1f-4d3c-9378-dda9d48cefc0	13	feasible	\N
21168	00000000-0000-0000-0000-000000000003	04fc7e24-26f9-4d92-b9c3-0b4895586177	13	feasible	\N
21169	00000000-0000-0000-0000-000000000003	99c914b9-0c1f-4af9-b40b-41bf0e93237f	13	feasible	\N
21170	00000000-0000-0000-0000-000000000003	4a80c54a-05b1-4834-839a-a24ce4198d8d	13	feasible	\N
21171	00000000-0000-0000-0000-000000000003	9a970ac8-0f39-4a73-8a53-9b63cbc3fce3	13	feasible	\N
21172	00000000-0000-0000-0000-000000000003	28852677-7717-4564-8fd9-42db5516df97	13	feasible	\N
21173	00000000-0000-0000-0000-000000000003	a5e8906d-68a3-450f-b306-14771f86b533	13	feasible	\N
21174	00000000-0000-0000-0000-000000000003	0c49c197-f9da-44bf-993f-9d4d4939048b	13	feasible	\N
21175	00000000-0000-0000-0000-000000000003	3db27605-e7ed-4310-9dae-db087d232e21	13	feasible	\N
21176	00000000-0000-0000-0000-000000000003	f9056fc4-6774-456f-a6a1-debb8ffcdbb6	13	feasible	\N
21177	00000000-0000-0000-0000-000000000003	db88f222-9e5f-4eea-ad8f-78b8b324139a	13	help	\N
21178	00000000-0000-0000-0000-000000000003	373bfd6d-b769-48cd-a6a0-d51308d98b06	13	feasible	\N
21179	00000000-0000-0000-0000-000000000003	fe049fa9-7af5-4b27-b744-4a36076b2ff1	13	feasible	\N
21180	00000000-0000-0000-0000-000000000003	2071294f-e736-4d92-a6fc-092471fdc25e	13	feasible	\N
21181	00000000-0000-0000-0000-000000000003	4da3ea7d-d1ca-42eb-a34b-1d6d8e3e4ede	13	feasible	\N
21182	00000000-0000-0000-0000-000000000003	dbeb2a22-04e9-47f3-a6e3-5414d47ba57b	13	feasible	\N
21183	00000000-0000-0000-0000-000000000003	9956a0e9-2e1f-4c60-9efc-a5ee748ce704	13	feasible	\N
21184	00000000-0000-0000-0000-000000000003	b7f477d6-f40f-44b3-abd0-de8ff19c91d3	13	feasible	\N
21185	00000000-0000-0000-0000-000000000003	276a0b97-3842-470c-a4c0-79175e1b4927	13	feasible	\N
21186	00000000-0000-0000-0000-000000000003	07f11fd8-a107-4955-9cfb-94548407be49	13	feasible	\N
21187	00000000-0000-0000-0000-000000000003	94b8f229-3cc6-4e63-876a-c587489d6cef	13	feasible	\N
21188	00000000-0000-0000-0000-000000000003	976abcff-7801-47e7-bf81-109f8d8d64d6	13	feasible	\N
21189	00000000-0000-0000-0000-000000000003	8e0913d1-a4f2-47fc-8943-80a905760d3f	13	feasible	\N
21190	00000000-0000-0000-0000-000000000003	63aba3fb-5d8e-4109-83bc-e3d231da5173	13	feasible	\N
21191	00000000-0000-0000-0000-000000000003	65d5c59d-91eb-4c54-9af6-2b2746499189	13	feasible	\N
21192	00000000-0000-0000-0000-000000000003	3910cf58-815c-45c6-8fe3-142bc48029ad	13	feasible	\N
21193	00000000-0000-0000-0000-000000000003	e32d4c0b-bdb3-4ccd-a84c-5b0ddfceb1d7	13	feasible	\N
21194	00000000-0000-0000-0000-000000000003	781630d0-8eeb-4f63-9718-3de081c42134	13	feasible	\N
21195	00000000-0000-0000-0000-000000000003	4622feb4-ea1e-462f-9072-cfdc77ae5d2c	13	feasible	\N
21196	00000000-0000-0000-0000-000000000003	c1afec34-decd-41c0-9acf-accbed9e2de4	13	feasible	\N
21197	00000000-0000-0000-0000-000000000003	605eef49-27d4-4eb3-a2c4-ca2d089a4449	13	help	\N
21198	00000000-0000-0000-0000-000000000003	53f590aa-29fb-4ecd-b206-4651114355b3	13	help	\N
21199	00000000-0000-0000-0000-000000000003	83d9d4f2-fa36-408a-a4e9-5e3c072f4878	13	help	\N
21200	00000000-0000-0000-0000-000000000003	1a96870e-beb8-49e2-b0db-1a4fd1e6345e	13	feasible	\N
21201	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	14	feasible	\N
21202	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	14	feasible	\N
21203	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	14	feasible	\N
21204	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	14	feasible	\N
21205	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	14	feasible	\N
21206	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	14	feasible	\N
21207	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	14	feasible	\N
21208	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	14	feasible	\N
21209	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	14	feasible	\N
21210	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	14	feasible	\N
21211	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	14	feasible	\N
21212	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	14	feasible	\N
21213	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	14	feasible	\N
21214	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	14	help	\N
21215	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	14	feasible	\N
21216	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	14	feasible	\N
21217	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	14	feasible	\N
21218	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	14	feasible	\N
21219	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	14	feasible	\N
21220	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	14	feasible	\N
21221	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	14	feasible	\N
21222	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	14	feasible	\N
21223	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	14	feasible	\N
21224	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	14	feasible	\N
21225	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	14	feasible	\N
21226	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	14	feasible	\N
21227	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	14	feasible	\N
21228	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	14	feasible	\N
21229	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	14	feasible	\N
21230	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	14	feasible	\N
21231	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	14	feasible	\N
21232	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	14	feasible	\N
21233	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	14	feasible	\N
21234	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	14	feasible	\N
21235	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	14	feasible	\N
21236	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	14	feasible	\N
21237	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	14	feasible	\N
21238	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	14	feasible	\N
21239	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	14	feasible	\N
21240	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	14	feasible	\N
21241	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	14	feasible	\N
21242	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	14	help	\N
21243	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	14	feasible	\N
21244	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	14	feasible	\N
21245	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	14	feasible	\N
21246	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	14	feasible	\N
21247	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	14	feasible	\N
21248	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	14	feasible	\N
21249	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	14	feasible	\N
21250	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	14	feasible	\N
21251	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	14	help	\N
21252	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	14	help	\N
21253	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	14	help	\N
21254	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	14	feasible	\N
21255	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	14	feasible	\N
21256	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	14	feasible	\N
21257	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	14	feasible	\N
21258	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	14	help	\N
21259	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	14	feasible	\N
21260	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	14	feasible	\N
21261	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	14	feasible	\N
21262	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	14	feasible	\N
21263	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	14	help	\N
21264	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	14	feasible	\N
21265	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	14	feasible	\N
21266	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	14	feasible	\N
21267	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	14	feasible	\N
21268	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	14	feasible	\N
21269	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	14	feasible	\N
21270	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	14	feasible	\N
21271	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	14	feasible	\N
21272	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	14	feasible	\N
21273	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	14	help	\N
21274	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	14	feasible	\N
21275	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	14	feasible	\N
21276	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	14	feasible	\N
21277	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	14	feasible	\N
21278	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	14	feasible	\N
21279	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	14	feasible	\N
21280	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	14	help	\N
21281	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	14	feasible	\N
21282	00000000-0000-0000-0000-000000000003	bd27b930-c86c-4cb7-bfa0-0c02866bd500	14	feasible	\N
21283	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	14	feasible	\N
21284	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	14	feasible	\N
21285	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	14	feasible	\N
21286	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	14	feasible	\N
21287	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	14	feasible	\N
21288	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	14	feasible	\N
21289	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	14	feasible	\N
21290	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	14	feasible	\N
21291	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	14	feasible	\N
21292	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	14	feasible	\N
21293	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	14	feasible	\N
21294	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	14	feasible	\N
21295	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	14	feasible	\N
21296	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	14	feasible	\N
21297	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	14	help	\N
21298	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	14	feasible	\N
21299	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	14	feasible	\N
21300	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	14	feasible	\N
21301	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	14	feasible	\N
21302	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	14	feasible	\N
21303	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	14	feasible	\N
21304	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	14	feasible	\N
21305	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	14	help	\N
21306	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	14	feasible	\N
21307	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	14	feasible	\N
21308	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	14	feasible	\N
21309	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	14	feasible	\N
21310	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	14	feasible	\N
21311	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	14	feasible	\N
21312	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	14	feasible	\N
21313	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	14	feasible	\N
21314	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	14	feasible	\N
21315	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	14	feasible	\N
21316	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	14	feasible	\N
21317	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	14	feasible	\N
21318	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	14	feasible	\N
21319	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	14	feasible	\N
21320	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	14	feasible	\N
21321	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	14	feasible	\N
21322	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	14	feasible	\N
21323	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	14	help	\N
21324	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	14	feasible	\N
21325	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	14	feasible	\N
21326	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	14	feasible	\N
21327	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	14	feasible	\N
21328	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	14	feasible	\N
21329	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	14	feasible	\N
21330	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	14	feasible	\N
21331	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	14	feasible	\N
21332	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	14	feasible	\N
21333	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	14	feasible	\N
21334	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	14	feasible	\N
21335	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	14	feasible	\N
21336	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	14	feasible	\N
21337	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	14	feasible	\N
21338	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	14	feasible	\N
21339	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	14	help	\N
21340	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	14	help	\N
21341	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	14	help	\N
21342	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	14	help	\N
21343	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	14	feasible	\N
21344	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	14	feasible	\N
21345	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	14	feasible	\N
21346	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	14	feasible	\N
21347	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	14	feasible	\N
21348	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	14	feasible	\N
21349	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	14	feasible	\N
21350	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	14	feasible	\N
21351	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	14	feasible	\N
21352	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	14	feasible	\N
21353	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	14	feasible	\N
21354	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	14	feasible	\N
21355	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	14	feasible	\N
21356	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	14	feasible	\N
21357	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	14	help	\N
21358	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	14	help	\N
21359	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	14	help	\N
21360	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	15	feasible	\N
21361	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	15	feasible	\N
21362	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	15	feasible	\N
21363	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	15	feasible	\N
21364	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	15	feasible	\N
21365	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	15	feasible	\N
21366	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	15	feasible	\N
21367	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	15	feasible	\N
21368	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	15	feasible	\N
21369	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	15	feasible	\N
21370	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	15	feasible	\N
21371	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	15	feasible	\N
21372	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	15	feasible	\N
21373	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	15	help	\N
21374	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	15	feasible	\N
21375	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	15	feasible	\N
21376	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	15	feasible	\N
21377	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	15	feasible	\N
21378	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	15	feasible	\N
21379	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	15	feasible	\N
21380	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	15	feasible	\N
21381	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	15	feasible	\N
21382	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	15	feasible	\N
21383	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	15	feasible	\N
21384	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	15	feasible	\N
21385	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	15	feasible	\N
21386	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	15	feasible	\N
21387	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	15	feasible	\N
21388	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	15	feasible	\N
21389	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	15	feasible	\N
21390	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	15	feasible	\N
21391	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	15	feasible	\N
21392	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	15	feasible	\N
21393	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	15	feasible	\N
21394	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	15	feasible	\N
21395	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	15	feasible	\N
21396	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	15	feasible	\N
21397	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	15	feasible	\N
21398	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	15	feasible	\N
21399	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	15	feasible	\N
21400	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	15	feasible	\N
21401	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	15	help	\N
21402	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	15	feasible	\N
21403	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	15	feasible	\N
21404	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	15	feasible	\N
21405	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	15	feasible	\N
21406	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	15	feasible	\N
21407	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	15	feasible	\N
21408	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	15	feasible	\N
21409	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	15	feasible	\N
21410	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	15	help	\N
21411	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	15	help	\N
21412	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	15	help	\N
21413	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	15	feasible	\N
21414	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	15	feasible	\N
21415	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	15	feasible	\N
21416	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	15	feasible	\N
21417	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	15	help	\N
21418	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	15	feasible	\N
21419	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	15	feasible	\N
21420	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	15	feasible	\N
21421	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	15	help	\N
21422	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	15	help	\N
21423	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	15	feasible	\N
21424	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	15	help	\N
21425	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	15	feasible	\N
21426	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	15	feasible	\N
21427	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	15	feasible	\N
21428	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	15	feasible	\N
21429	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	15	feasible	\N
21430	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	15	feasible	\N
21431	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	15	feasible	\N
21432	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	15	help	\N
21433	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	15	feasible	\N
21434	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	15	help	\N
21435	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	15	feasible	\N
21436	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	15	feasible	\N
21437	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	15	feasible	\N
21438	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	15	feasible	\N
21439	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	15	help	\N
21440	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	15	feasible	\N
21441	00000000-0000-0000-0000-000000000003	bd27b930-c86c-4cb7-bfa0-0c02866bd500	15	help	\N
21442	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	15	feasible	\N
21443	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	15	feasible	\N
21444	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	15	feasible	\N
21445	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	15	feasible	\N
21446	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	15	feasible	\N
21447	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	15	feasible	\N
21448	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	15	help	\N
21449	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	15	help	\N
21450	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	15	feasible	\N
21451	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	15	feasible	\N
21452	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	15	feasible	\N
21453	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	15	feasible	\N
21454	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	15	feasible	\N
21455	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	15	help	\N
21456	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	15	help	\N
21457	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	15	feasible	\N
21458	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	15	feasible	\N
21459	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	15	feasible	\N
21460	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	15	feasible	\N
21461	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	15	feasible	\N
21462	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	15	feasible	\N
21463	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	15	feasible	\N
21464	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	15	help	\N
21465	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	15	feasible	\N
21466	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	15	feasible	\N
21467	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	15	feasible	\N
21468	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	15	feasible	\N
21469	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	15	feasible	\N
21470	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	15	feasible	\N
21471	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	15	feasible	\N
21472	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	15	feasible	\N
21473	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	15	feasible	\N
21474	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	15	feasible	\N
21475	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	15	feasible	\N
21476	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	15	feasible	\N
21477	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	15	feasible	\N
21478	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	15	feasible	\N
21479	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	15	feasible	\N
21480	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	15	feasible	\N
21481	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	15	feasible	\N
21482	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	15	help	\N
21483	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	15	feasible	\N
21484	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	15	feasible	\N
21485	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	15	feasible	\N
21486	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	15	feasible	\N
21487	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	15	feasible	\N
21488	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	15	feasible	\N
21489	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	15	feasible	\N
21490	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	15	feasible	\N
21491	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	15	feasible	\N
21492	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	15	feasible	\N
21493	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	15	feasible	\N
21494	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	15	feasible	\N
21495	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	15	feasible	\N
21496	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	15	feasible	\N
21497	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	15	feasible	\N
21498	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	15	help	\N
21499	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	15	help	\N
21500	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	15	help	\N
21501	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	15	help	\N
21502	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	15	feasible	\N
21503	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	15	feasible	\N
21504	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	15	feasible	\N
21505	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	15	feasible	\N
21506	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	15	feasible	\N
21507	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	15	feasible	\N
21508	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	15	feasible	\N
21509	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	15	feasible	\N
21510	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	15	feasible	\N
21511	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	15	feasible	\N
21512	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	15	feasible	\N
21513	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	15	feasible	\N
21514	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	15	feasible	\N
21515	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	15	feasible	\N
21516	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	15	help	\N
21517	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	15	help	\N
21518	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	15	help	\N
21519	00000000-0000-0000-0000-000000000003	a1456689-ee73-4dc6-b59c-4d7b56cf23c2	16	feasible	\N
21520	00000000-0000-0000-0000-000000000003	d4568582-6e47-4eff-a21d-838d2cb6316d	16	feasible	\N
21521	00000000-0000-0000-0000-000000000003	5ea8f03f-b153-4b35-a039-27af1812b572	16	feasible	\N
21522	00000000-0000-0000-0000-000000000003	1e496c96-3999-4eee-93c2-d6944dd641e5	16	feasible	\N
21523	00000000-0000-0000-0000-000000000003	74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	16	feasible	\N
21524	00000000-0000-0000-0000-000000000003	f696b8fc-6554-41c4-8bee-7494261fa794	16	feasible	\N
21525	00000000-0000-0000-0000-000000000003	50001b6b-3830-4975-b241-9d5149d6ef3c	16	feasible	\N
21526	00000000-0000-0000-0000-000000000003	82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	16	feasible	\N
21527	00000000-0000-0000-0000-000000000003	124a6c93-87e6-4d1a-95e9-ddccc64a7d05	16	feasible	\N
21528	00000000-0000-0000-0000-000000000003	1c0c582f-143e-409b-899c-ec13a29b8530	16	feasible	\N
21529	00000000-0000-0000-0000-000000000003	4d0fed30-95bd-4f80-89a8-eba5620ffc46	16	feasible	\N
21530	00000000-0000-0000-0000-000000000003	f02526fe-a22c-4a4d-81e5-f0d70f523052	16	feasible	\N
21531	00000000-0000-0000-0000-000000000003	73baed07-321a-4f1e-b157-669730841cea	16	feasible	\N
21532	00000000-0000-0000-0000-000000000003	04617382-75bb-45e1-9068-1e486f418c54	16	help	\N
21533	00000000-0000-0000-0000-000000000003	3d3a35ca-574e-4498-b804-f6a823596fd7	16	feasible	\N
21534	00000000-0000-0000-0000-000000000003	1a75aa48-c5a4-4890-b502-c20ef4b19507	16	feasible	\N
21535	00000000-0000-0000-0000-000000000003	4f2587f2-ffd9-43a2-94d3-fda939b2db80	16	feasible	\N
21536	00000000-0000-0000-0000-000000000003	23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	16	feasible	\N
21537	00000000-0000-0000-0000-000000000003	884841a8-25b6-4127-b0b5-024406c27a5d	16	feasible	\N
21538	00000000-0000-0000-0000-000000000003	cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	16	feasible	\N
21539	00000000-0000-0000-0000-000000000003	773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	16	feasible	\N
21540	00000000-0000-0000-0000-000000000003	005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	16	feasible	\N
21541	00000000-0000-0000-0000-000000000003	36728579-5842-4fb3-9e43-edd90cc08df9	16	feasible	\N
21542	00000000-0000-0000-0000-000000000003	6a18c664-b262-417f-9136-361a5f5ea004	16	feasible	\N
21543	00000000-0000-0000-0000-000000000003	5b7526ca-a9a6-4912-8e7c-3efba9362d78	16	feasible	\N
21544	00000000-0000-0000-0000-000000000003	173ae9df-af7a-4f19-807e-e62365592475	16	feasible	\N
21545	00000000-0000-0000-0000-000000000003	c3815c3b-73ff-4488-812b-266f0f2e7a4e	16	feasible	\N
21546	00000000-0000-0000-0000-000000000003	c44690f1-ac3d-4658-a064-45abeef197a5	16	feasible	\N
21547	00000000-0000-0000-0000-000000000003	fb45530a-d711-4b73-9286-7b3679a89a1a	16	feasible	\N
21548	00000000-0000-0000-0000-000000000003	726082a5-78dd-491c-ad9b-4193f67bacec	16	feasible	\N
21549	00000000-0000-0000-0000-000000000003	4d5a7b2b-9e9c-4761-a052-1dda5467150f	16	feasible	\N
21550	00000000-0000-0000-0000-000000000003	d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	16	feasible	\N
21551	00000000-0000-0000-0000-000000000003	dbe8e556-37d8-4981-b248-06d0530a27c2	16	feasible	\N
21552	00000000-0000-0000-0000-000000000003	13d22b7c-8bd6-4876-9ceb-9baff4152a74	16	feasible	\N
21553	00000000-0000-0000-0000-000000000003	4d87ddf6-a2e2-47cb-8724-c1a04b891290	16	feasible	\N
21554	00000000-0000-0000-0000-000000000003	c40e69f9-bdf0-4532-bbcb-288d361fc73a	16	feasible	\N
21555	00000000-0000-0000-0000-000000000003	92f54406-8519-455e-83a4-019531cc1224	16	feasible	\N
21556	00000000-0000-0000-0000-000000000003	aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	16	feasible	\N
21557	00000000-0000-0000-0000-000000000003	42dbc9ce-19cf-4bbb-92de-1412be336be5	16	feasible	\N
21558	00000000-0000-0000-0000-000000000003	39dee73b-cb41-4108-b45e-3ae033611a21	16	feasible	\N
21559	00000000-0000-0000-0000-000000000003	731d63c6-78b9-4dae-84f2-16a7240f143e	16	feasible	\N
21560	00000000-0000-0000-0000-000000000003	bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	16	help	\N
21561	00000000-0000-0000-0000-000000000003	a2238841-605c-4420-bd8d-1a3bcb4fe242	16	feasible	\N
21562	00000000-0000-0000-0000-000000000003	a30a3b83-6692-4900-8196-b86c71799bd7	16	feasible	\N
21563	00000000-0000-0000-0000-000000000003	c23ea9dd-6892-43c1-bafd-21eabc052e24	16	feasible	\N
21564	00000000-0000-0000-0000-000000000003	2b5c97c0-73bf-40e8-aa28-fc98cb659e46	16	feasible	\N
21565	00000000-0000-0000-0000-000000000003	ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	16	feasible	\N
21566	00000000-0000-0000-0000-000000000003	edcd977c-c531-4ecb-83f1-9865e96c0fba	16	feasible	\N
21567	00000000-0000-0000-0000-000000000003	e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	16	feasible	\N
21568	00000000-0000-0000-0000-000000000003	e855bdf4-a0ec-482f-82b2-a879a82e6e4e	16	feasible	\N
21569	00000000-0000-0000-0000-000000000003	bde313aa-5711-4500-80f1-30b222acc6c4	16	help	\N
21570	00000000-0000-0000-0000-000000000003	bf92ac9f-7c4e-4432-8791-9571edee81d5	16	help	\N
21571	00000000-0000-0000-0000-000000000003	c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	16	help	\N
21572	00000000-0000-0000-0000-000000000003	f1e6927c-74c0-438c-ac06-86ee0dbba457	16	feasible	\N
21573	00000000-0000-0000-0000-000000000003	b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	16	feasible	\N
21574	00000000-0000-0000-0000-000000000003	9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	16	feasible	\N
21575	00000000-0000-0000-0000-000000000003	90ded60a-f3b6-4d91-967a-70895e4d911c	16	feasible	\N
21576	00000000-0000-0000-0000-000000000003	681ff20e-9933-4d75-8591-03404b931179	16	help	\N
21577	00000000-0000-0000-0000-000000000003	b64adc8e-0cdd-4d44-a61b-8345dfbe3374	16	feasible	\N
21578	00000000-0000-0000-0000-000000000003	1638aa2d-0ad8-4951-a45f-b8fb098118bb	16	feasible	\N
21579	00000000-0000-0000-0000-000000000003	bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	16	feasible	\N
21580	00000000-0000-0000-0000-000000000003	cce2a154-8a19-491d-9f10-9ea5223e0cdb	16	help	\N
21581	00000000-0000-0000-0000-000000000003	7640240b-b2e6-40da-801b-9469a3199d73	16	help	\N
21582	00000000-0000-0000-0000-000000000003	0ab8beb4-7eb8-4468-95fa-823e4b7fb707	16	feasible	\N
21583	00000000-0000-0000-0000-000000000003	462434f9-7d39-4e83-bbd2-dd2f07839922	16	help	\N
21584	00000000-0000-0000-0000-000000000003	49f4bd28-2d63-492b-8646-7fb43172aaff	16	feasible	\N
21585	00000000-0000-0000-0000-000000000003	78e69688-1a23-48a4-ae78-b457b8dccbb9	16	feasible	\N
21586	00000000-0000-0000-0000-000000000003	53f5cee7-183f-4b8e-b2f2-273af065475d	16	feasible	\N
21587	00000000-0000-0000-0000-000000000003	79680df7-8efd-4445-92a5-8531cd5ed94e	16	feasible	\N
21588	00000000-0000-0000-0000-000000000003	89330a6f-698c-46f7-a259-e17894df0a36	16	feasible	\N
21589	00000000-0000-0000-0000-000000000003	bd41797b-72da-4723-9f3c-f818b7e7d3b1	16	feasible	\N
21590	00000000-0000-0000-0000-000000000003	d395acf5-69ab-42ac-9842-12504ba79aea	16	feasible	\N
21591	00000000-0000-0000-0000-000000000003	b481d209-fce8-4994-8d06-a95c95bf5d3d	16	help	\N
21592	00000000-0000-0000-0000-000000000003	3e15e92a-5c87-4220-aba0-f77f4f81b23a	16	feasible	\N
21593	00000000-0000-0000-0000-000000000003	cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	16	help	\N
21594	00000000-0000-0000-0000-000000000003	527ed95b-2212-4ecd-acff-d79a2aea8894	16	feasible	\N
21595	00000000-0000-0000-0000-000000000003	f08fa4cc-6ac0-4b85-b4fe-16d352d62647	16	feasible	\N
21596	00000000-0000-0000-0000-000000000003	dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	16	feasible	\N
21597	00000000-0000-0000-0000-000000000003	1853dce4-23b1-4057-a6a5-38b1eb06d5aa	16	feasible	\N
21598	00000000-0000-0000-0000-000000000003	586f4614-4e43-4ada-bdd9-a6c2c2737c0c	16	help	\N
21599	00000000-0000-0000-0000-000000000003	7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	16	feasible	\N
21600	00000000-0000-0000-0000-000000000003	bd27b930-c86c-4cb7-bfa0-0c02866bd500	16	help	\N
21601	00000000-0000-0000-0000-000000000003	64fe5498-d87a-473e-b3ed-771e89bf9753	16	feasible	\N
21602	00000000-0000-0000-0000-000000000003	5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	16	feasible	\N
21603	00000000-0000-0000-0000-000000000003	81f975f0-e0ef-4b99-b419-99ce1b04c284	16	feasible	\N
21604	00000000-0000-0000-0000-000000000003	9225324d-82da-4f20-9d75-b60ad8b5b9d9	16	feasible	\N
21605	00000000-0000-0000-0000-000000000003	b2c89e2f-f462-4b55-8c65-f28190f32d63	16	feasible	\N
21606	00000000-0000-0000-0000-000000000003	eb6eee08-7836-4728-81d7-040d4d8a3d01	16	feasible	\N
21607	00000000-0000-0000-0000-000000000003	bea31ac3-0080-483b-8044-1037f6e60a4b	16	help	\N
21608	00000000-0000-0000-0000-000000000003	cf2eeec2-8d01-4476-acbb-6d4fa33a5476	16	help	\N
21609	00000000-0000-0000-0000-000000000003	bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	16	feasible	\N
21610	00000000-0000-0000-0000-000000000003	5810a0f6-d852-455b-81eb-d0ad232269e4	16	feasible	\N
21611	00000000-0000-0000-0000-000000000003	d12993d0-4afe-4302-9945-ae7112a55e99	16	feasible	\N
21612	00000000-0000-0000-0000-000000000003	44fcb91b-bf28-486d-9ccc-a191d5a8281a	16	feasible	\N
21613	00000000-0000-0000-0000-000000000003	43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	16	feasible	\N
21614	00000000-0000-0000-0000-000000000003	2f7a1251-c86b-42de-bff8-48a516307a6d	16	help	\N
21615	00000000-0000-0000-0000-000000000003	86698d0a-9315-4351-bcf9-8d2c14c60072	16	help	\N
21616	00000000-0000-0000-0000-000000000003	6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	16	feasible	\N
21617	00000000-0000-0000-0000-000000000003	5200ebeb-13b4-40fd-8cdd-89c8c439bde9	16	feasible	\N
21618	00000000-0000-0000-0000-000000000003	b1d30365-2fab-463c-a541-c871f4e6f0de	16	feasible	\N
21619	00000000-0000-0000-0000-000000000003	2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	16	feasible	\N
21620	00000000-0000-0000-0000-000000000003	12023c28-4903-472c-9086-0b55f8617b9c	16	feasible	\N
21621	00000000-0000-0000-0000-000000000003	b89722f4-8a66-47df-88e6-60944f871fc4	16	feasible	\N
21622	00000000-0000-0000-0000-000000000003	6c0d699e-4fd8-4865-b6e8-a88747b3cb18	16	feasible	\N
21623	00000000-0000-0000-0000-000000000003	1182adaa-3f83-4f61-b923-6b64c2c63582	16	help	\N
21624	00000000-0000-0000-0000-000000000003	eb3365d0-38dc-4f28-8fa6-f172af6a0a58	16	feasible	\N
21625	00000000-0000-0000-0000-000000000003	9926311e-561a-4681-9047-43043f3aad54	16	feasible	\N
21626	00000000-0000-0000-0000-000000000003	b0251a4d-eea3-4daf-8765-143faa54688f	16	feasible	\N
21627	00000000-0000-0000-0000-000000000003	a567e49a-f9e4-438f-ab5e-5eabac5c0a51	16	feasible	\N
21628	00000000-0000-0000-0000-000000000003	2f373e80-bbad-42a2-9e2f-f66d4d64566f	16	feasible	\N
21629	00000000-0000-0000-0000-000000000003	5c142fc3-bcec-4597-a84b-5f6ce784b592	16	feasible	\N
21630	00000000-0000-0000-0000-000000000003	21ae459e-2e52-46c0-9def-ef36dfa91b03	16	feasible	\N
21631	00000000-0000-0000-0000-000000000003	51938600-c805-4127-86b8-dbeab405115d	16	feasible	\N
21632	00000000-0000-0000-0000-000000000003	b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	16	feasible	\N
21633	00000000-0000-0000-0000-000000000003	4d536e13-c834-4e30-9330-66717d2a1d08	16	feasible	\N
21634	00000000-0000-0000-0000-000000000003	5500b573-6588-4974-b933-7cfddc236101	16	feasible	\N
21635	00000000-0000-0000-0000-000000000003	b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	16	feasible	\N
21636	00000000-0000-0000-0000-000000000003	b92a17b4-3191-41a3-b746-3ecf58c0396f	16	feasible	\N
21637	00000000-0000-0000-0000-000000000003	9952ce7e-522f-4b83-bda3-9b2b01adb18f	16	feasible	\N
21638	00000000-0000-0000-0000-000000000003	872d8a14-ffd4-4697-b419-4e677341e59e	16	feasible	\N
21639	00000000-0000-0000-0000-000000000003	949629ca-7c88-4a9a-a964-732196b2e990	16	feasible	\N
21640	00000000-0000-0000-0000-000000000003	320c5646-481c-4a03-bdc9-f4ab05037452	16	feasible	\N
21641	00000000-0000-0000-0000-000000000003	a685776c-ba90-4d8c-b3ab-49bbde673a33	16	help	\N
21642	00000000-0000-0000-0000-000000000003	36b02f08-0783-48b3-b3f2-bd8d2ddf784a	16	feasible	\N
21643	00000000-0000-0000-0000-000000000003	31ea94d3-9576-4667-943c-a51276d58148	16	feasible	\N
21644	00000000-0000-0000-0000-000000000003	f47caa82-ac9f-4444-a73a-6445603984ff	16	feasible	\N
21645	00000000-0000-0000-0000-000000000003	a701e4c1-fee5-4fec-88e7-240be5c2e34f	16	feasible	\N
21646	00000000-0000-0000-0000-000000000003	c46f7501-4216-4348-87da-7673ba847b8b	16	feasible	\N
21647	00000000-0000-0000-0000-000000000003	ddd15ebe-213e-4303-87d0-323c6908516a	16	feasible	\N
21648	00000000-0000-0000-0000-000000000003	c8c6473b-4c8b-45e1-890d-e50a4ed96513	16	feasible	\N
21649	00000000-0000-0000-0000-000000000003	c7acc9b8-4729-49df-9e0c-063f36837da9	16	feasible	\N
21650	00000000-0000-0000-0000-000000000003	bfd11416-3212-4ce5-9962-9d00167c149b	16	feasible	\N
21651	00000000-0000-0000-0000-000000000003	53dbf8a1-98fb-4991-a346-8481101f68ce	16	feasible	\N
21652	00000000-0000-0000-0000-000000000003	12e5974f-3e7d-4057-a98e-e51933e1f900	16	feasible	\N
21653	00000000-0000-0000-0000-000000000003	1054d713-bd15-4545-988d-4fc249eed707	16	feasible	\N
21654	00000000-0000-0000-0000-000000000003	84dfdb7d-2d8f-405c-999e-08f9d6c22bda	16	feasible	\N
21655	00000000-0000-0000-0000-000000000003	491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	16	feasible	\N
21656	00000000-0000-0000-0000-000000000003	e0797b12-9c57-4599-931b-372ffbc60ba2	16	feasible	\N
21657	00000000-0000-0000-0000-000000000003	474f5b55-2348-4b48-8e2e-3e173b74e6b1	16	help	\N
21658	00000000-0000-0000-0000-000000000003	eab9b00d-6be4-4db0-9836-f1dff88bb12a	16	help	\N
21659	00000000-0000-0000-0000-000000000003	93848e63-5354-479a-a050-8949add0c942	16	help	\N
21660	00000000-0000-0000-0000-000000000003	ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	16	help	\N
21661	00000000-0000-0000-0000-000000000003	acc6e165-768b-4882-89c6-6361c0a3c94c	16	feasible	\N
21662	00000000-0000-0000-0000-000000000003	b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	16	feasible	\N
21663	00000000-0000-0000-0000-000000000003	34580f0f-ec01-4b34-ad24-db8f6bcf6bad	16	feasible	\N
21664	00000000-0000-0000-0000-000000000003	268cd74a-bc7a-4fea-8282-6f286febb453	16	feasible	\N
21665	00000000-0000-0000-0000-000000000003	8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	16	feasible	\N
21666	00000000-0000-0000-0000-000000000003	7a7fab97-8d75-4903-ab6a-d48f02e69f3c	16	feasible	\N
21667	00000000-0000-0000-0000-000000000003	e644e850-745a-4c00-98cc-1c8c88e75652	16	feasible	\N
21668	00000000-0000-0000-0000-000000000003	a6d79885-ad38-4a37-a9d9-faf425476dc3	16	feasible	\N
21669	00000000-0000-0000-0000-000000000003	e4ba9c2c-945e-4502-8da4-47d9c2fefb38	16	feasible	\N
21670	00000000-0000-0000-0000-000000000003	e71cc75c-13e8-4e42-9cba-122b1dac4f92	16	feasible	\N
21671	00000000-0000-0000-0000-000000000003	be6356ad-5aa1-415a-855e-f589c2daf110	16	feasible	\N
21672	00000000-0000-0000-0000-000000000003	4e64fa79-aa97-4fdd-acaa-96246e07bbc6	16	feasible	\N
21673	00000000-0000-0000-0000-000000000003	075dceeb-824b-4dd5-b36d-22439cdcacc2	16	feasible	\N
21674	00000000-0000-0000-0000-000000000003	e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	16	feasible	\N
21675	00000000-0000-0000-0000-000000000003	cd720d62-0c42-4aa1-879f-865ba0ac4a61	16	help	\N
21676	00000000-0000-0000-0000-000000000003	12ec6081-17ef-466b-8a36-aceed0a8f40c	16	help	\N
21677	00000000-0000-0000-0000-000000000003	403c93d5-ada6-40e4-91b0-868dad813044	16	help	\N
\.


--
-- Data for Name: task_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_categories (id, name_fr, name_en, name_ar) FROM stdin;
1	Education personnelle	Personal education	المستوى التعليمي المطلوب
2	Stock stratégique	Strategic stock	المخزون الاستراتيجي
3	Mise en place	Setup / Mise en place	التحضير
4	Préparation	Preparation	التحضير
5	Préparer appareil	Prepare dough	تحضير العجين
6	Fondre le chocolat	Melt chocolate	تذوب الشوكولاته
7	Travail du chocolat	Chocolate workshop	عمل الشوكولاته
8	Moulage chocolat	Chocolate moulding	وضع في قالب
9	Enrobage chocolat	Chocolate enrobing	تغليف بالشوكولاتة
10	Décoration	Decoration	الزخرفة
11	Cuisson	Cooking / Baking	الطهي
12	Finition	Finishing	التشطيب
13	Education personnelle	Personal education	\N
14	Stock strategique	Par Stock	\N
15	Mise en place	Set up	\N
16	Fondre le chocolat	Melt chocolate	\N
17	Travail du chocolat	Chocolate workshop	\N
18	Enrobage	Coating	\N
19	Emballer	Pack	\N
20	Exposer	Expose - Display	\N
21	Servir clientele -Vente	Servicing clients - Sale	\N
22	Administration	Management	\N
23	Hygiene	Hygiene	\N
24	Stock strategique	Par Stok	\N
25	Position	Position	\N
26	Hybgiene alimentaire	Food hygiene	\N
27	Empaquetter	Wrap	\N
28	Preparer appareil	Prepare dough	\N
29	Production crème glacée et/ou sorbet	Ice cream and/or sorbet processing	\N
30	Vente glacerie (Gelateria)	Sale - Ice cream parlor	\N
31	Conclure une vente	Complete a sale	\N
32	Preparation	Preparation	\N
33	Préparer les pieces [viennoiseries]	Prepare [Danish]	\N
34	Produire	Produce	\N
35	Cuire	Bake	\N
36	Decorer	Decorate	\N
37	Exposer	Display	\N
38	Vendre	Sell	\N
39	Vider	Empty	\N
40	Saupoudrer	Sprinkle	\N
41	Verser	Pour	\N
42	Trancher	Slice	\N
43	Sceller	Seal	\N
44	Proteger	Protect	\N
45	Rendre monnaie	Give back	\N
46	Faire la caisse	Set up cash	\N
47	Émulsionner	Emulsify	\N
48	Nettoyer l'espace	Clean area	\N
\.


--
-- Data for Name: task_requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_requirements (id, task_id, ability_id, required_level, requirement_type) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, job_role_id, category_id, parent_task_id, name, name_fr, name_ar, description, is_optional, created_at, updated_at) FROM stdin;
db1e7475-a1e6-4c6c-9892-84da11a65e13	00000000-0000-0000-0000-000000000001	13	\N	Write	Ecrire	كتابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
85f37baa-20b6-44f4-8b81-0bac91f2e26c	00000000-0000-0000-0000-000000000001	13	\N	Read	Lire	قراءة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ca537841-6ca3-4f80-8649-d9ff37a4f3e7	00000000-0000-0000-0000-000000000001	13	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
166bd53d-51e8-456e-9ae8-0ba16bb00fed	00000000-0000-0000-0000-000000000001	13	\N	Basic confectionary knowledge to position	Connaissances culinaires appropriées	تعاليم الطبخ الاساسية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
374d5fe3-5ef3-4bbd-8581-6c845933d0ef	00000000-0000-0000-0000-000000000001	14	\N	Keep minimum stock	Maintenir un stock minimum	الحفاظ على  حد ادنى من المخزون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b97752de-0609-49fe-be07-67f954430fe4	00000000-0000-0000-0000-000000000001	14	\N	Take delivery of raw material	Réceptionner matière premiere	استلام المكونات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a385553c-89c5-4f38-94eb-c98254d7d1a3	00000000-0000-0000-0000-000000000001	14	\N	Quality control of products	Contrôler la qualité des produits	مراقبة النوعية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fccfe5f0-2d1a-48a2-a625-ee84fdb09dea	00000000-0000-0000-0000-000000000001	14	\N	Check daily order	Verifier commande journée	مراقبة الطلبات اليومية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
90f5d942-5169-48cd-8529-95481b73bd25	00000000-0000-0000-0000-000000000001	15	\N	Add	Additionner	تزويد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2dd46659-6392-46a4-a119-515c2b50c813	00000000-0000-0000-0000-000000000001	15	\N	Count	Compter	عد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ef8f0059-072a-4dc4-8a44-0c9cec6737cd	00000000-0000-0000-0000-000000000001	15	\N	Choose	Choisir	اختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bcdc2296-d4da-4f8b-9ca4-693ca6cfa4c7	00000000-0000-0000-0000-000000000001	15	\N	Itemize	Détailler	التفنيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dc752f45-0d09-49c1-ade3-e9ac077d3e01	00000000-0000-0000-0000-000000000001	15	\N	Mix	Mélanger	الخلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8feeb1ee-3a6e-4b2d-96a9-fa8fc47d3469	00000000-0000-0000-0000-000000000001	15	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b224191f-11d1-4a8b-963c-0efa96706602	00000000-0000-0000-0000-000000000001	15	\N	Place	Placer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0b8bc379-36f7-417f-84a8-80697af161e5	00000000-0000-0000-0000-000000000001	15	\N	Empty	Vider	افراغ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
479ea398-f09d-4f23-888b-a8222ffac900	00000000-0000-0000-0000-000000000001	16	\N	Select	Selectioner	اختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c9ece822-bcb8-4c31-8a8f-99aafb106b05	00000000-0000-0000-0000-000000000001	16	\N	Grate or shop	Gratter ou briser	خدش أو كسر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e3e47579-e91b-4519-88bc-a056fca12960	00000000-0000-0000-0000-000000000001	16	\N	Heat	Rechauffer	تسخين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
329c7cdc-5251-4721-9566-b8359f73e73c	00000000-0000-0000-0000-000000000001	16	\N	Temper	Temperer	تليين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
52296537-a3ea-4c8c-ab57-85a921b9ca24	00000000-0000-0000-0000-000000000001	16	\N	Stir	Melanger	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c4d6445a-5f5b-4a8d-ac10-a61ba0c207da	00000000-0000-0000-0000-000000000001	16	\N	Cool	Refroidir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a1c8b3ce-235d-48a8-8e94-391ae4d73333	00000000-0000-0000-0000-000000000001	16	\N	Test	Tester	اختبار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ad879e5b-9604-4ee1-a918-39a5948c1ebc	00000000-0000-0000-0000-000000000001	17	\N	Moulding	Moulage	وضع في قالب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
34015533-dac2-4758-b8b8-7b6e7226aeb3	00000000-0000-0000-0000-000000000001	17	\N	Choose mould	Choisir le moule	اختيار القالب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
650b6730-b952-42b1-a8ba-0afeab2fc4ea	00000000-0000-0000-0000-000000000001	17	\N	Temper	Temperer	تليين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b7df5eb2-b575-4812-a285-973db10c0d4d	00000000-0000-0000-0000-000000000001	17	\N	Poor chocolate	Verser le chocolat	صب الشوكولاته	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bdf493c2-62d9-476b-8a2a-384184843f8b	00000000-0000-0000-0000-000000000001	17	\N	Scrape exceding	Racler excedent	كشط الزائد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3a13367c-1116-4e5c-9065-9b23d0550546	00000000-0000-0000-0000-000000000001	17	\N	Shake mould	Faire vibrer	هز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6f9a8461-932e-4b10-9516-afc8213e8fc7	00000000-0000-0000-0000-000000000001	17	\N	Turn up down mould	Renverser moule	قلب القالب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ab3f69a6-5778-4147-84d3-87e75b93c9fb	00000000-0000-0000-0000-000000000001	17	\N	Add filling	Ajouter fourrage	أضف الحشو	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a70b7cfc-41ab-4016-bd19-62f875107f48	00000000-0000-0000-0000-000000000001	17	\N	Fill with chocolate	Couvrir chocolat	تغطية بالشوكولاته	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ac0f6563-5d5e-4eaa-9b5e-4e1c8d14bae3	00000000-0000-0000-0000-000000000001	17	\N	Cool	Refroidir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7f586bdc-9cc3-4388-b5bd-31e59b33019a	00000000-0000-0000-0000-000000000001	17	\N	Turn out	Demouler	تحويل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2d66ea68-0ee0-4901-820f-f10ef56d6961	00000000-0000-0000-0000-000000000001	17	\N	Store in fresh place	Stocker au frais	تخزينها في مكان بارد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f451d903-2e24-46a8-a0d4-10f0ff2a443f	00000000-0000-0000-0000-000000000001	18	\N	Select pieces	Préparer pieces	اختيار القطع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2b6b4f66-1906-42bc-9578-1bcd388c0bef	00000000-0000-0000-0000-000000000001	18	\N	Select ingredients	Selectioner ingredients	حدد المكونات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
300ef7f7-4c5d-43e7-a55f-6a12f5cc3857	00000000-0000-0000-0000-000000000001	18	\N	Cut	Decouper	تقطيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
34f74e69-7f22-4570-9708-5250067b05a3	00000000-0000-0000-0000-000000000001	18	\N	Split	Séparer	فرز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1840f7c3-a632-490c-9b7e-55464494e547	00000000-0000-0000-0000-000000000001	18	\N	Mix	Mélanger	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e4dffc1b-3f32-4ec7-a89c-06ff086957eb	00000000-0000-0000-0000-000000000001	18	\N	Shape	Faconner	تشكيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9aaaec92-435b-428d-9337-045b0227b8e4	00000000-0000-0000-0000-000000000001	18	\N	Prepare piece	Préparer piece	تحضير قطعة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
125d5605-3a61-4a8a-b748-4ea8d7edf22b	00000000-0000-0000-0000-000000000001	18	\N	Coat by hand	Enrober manuellement	تعطيف باليد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1bb5673f-5db1-4269-8523-1e8c4eb8923a	00000000-0000-0000-0000-000000000001	18	\N	Coat by enrobing machine	Enrobage machine	تعطيف بواسطة آلة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5ba89138-3e22-4ceb-b48a-8b29eeb65a7b	00000000-0000-0000-0000-000000000001	18	\N	Drip - dry	Egoutter	تنقيط - تجفيف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e5bdbbd4-634d-48bc-9a0e-1bd6a407f011	00000000-0000-0000-0000-000000000001	18	\N	Cool	Refroidir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0557a635-8836-4012-b0dd-bc2373a7e2cc	00000000-0000-0000-0000-000000000001	18	\N	Store in fresh place	Stocker au frais	حفظ  في مكان بارد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e803ce31-66bb-4579-8f28-a6dc85e3e6da	00000000-0000-0000-0000-000000000001	19	\N	Prepare package	Préparer emballage	إعداد الحزمة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d6ae40bd-5319-4b29-9588-ed9369ed7420	00000000-0000-0000-0000-000000000001	19	\N	Open	Ouvrir	افتح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0d59f45a-bbf1-4dd0-8069-6aacd41fc045	00000000-0000-0000-0000-000000000001	19	\N	Slide	Glisser	الانزلاق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6a9326cd-7045-43ce-8510-c2593df9b46f	00000000-0000-0000-0000-000000000001	19	\N	Wrap	Empaquetter	لف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fd48dcc8-a1fa-48c0-a5a1-3f429e95582a	00000000-0000-0000-0000-000000000001	19	\N	Put sticker	Etiqueter	وضع الملصق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3b785d6b-9768-4ab6-9d0b-0d8de17fb09d	00000000-0000-0000-0000-000000000001	19	\N	Close	Fermer	أغلق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a6ba718b-23c9-499c-9557-f0c31498c1b4	00000000-0000-0000-0000-000000000001	19	\N	Seal	Sceller	اغلاق محكم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6a860717-662a-4cb3-bdfa-f8e8153cf754	00000000-0000-0000-0000-000000000001	20	\N	Display products	Préparer etalage	عرض المنتجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
27ea0a14-0028-49c8-8848-16be577284a0	00000000-0000-0000-0000-000000000001	20	\N	Keep under hand	Disposer	بمتناول اليد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
06137f6e-e65d-4a1d-b16d-225bbe4a1bf5	00000000-0000-0000-0000-000000000001	20	\N	Pricing	Mettre les prix	التسعير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dcf60a74-ad02-4788-bf7d-509c702afe2b	00000000-0000-0000-0000-000000000001	21	\N	Greet client	Acceuillir client	استقبال الزبائن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
eb7a2b47-adff-4fb1-a198-449d364b3e4a	00000000-0000-0000-0000-000000000001	21	\N	Look after selling point	Entretenir un espace de vente	الحفاظ على منطقة المبيعات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b5890670-17c1-4ae7-b878-9bc59e12103e	00000000-0000-0000-0000-000000000001	21	\N	Inform client	Renseigner un client	اعلام الزبون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ad52ebca-fafe-4118-965d-b1c294e06b78	00000000-0000-0000-0000-000000000001	21	\N	Advise	Conseiller	اعطاء النصائح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0891e5f5-a2ee-4b4a-9727-98bb107b2088	00000000-0000-0000-0000-000000000001	21	\N	Take order	Prendre la commande des clients	استلام الطلبات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
367cc25c-50cd-4f82-940b-cec18d3c6cf0	00000000-0000-0000-0000-000000000001	21	\N	Sell products or services	Vendre des produits ou services	بيع المنتجات أو الخدمات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5b663a9d-a971-461c-86ab-73e2f950428c	00000000-0000-0000-0000-000000000001	21	\N	Complete a sale	Conclure une vente	اتمام البيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5a90ee4a-313f-4fca-b9b0-a895ee7724bc	00000000-0000-0000-0000-000000000001	21	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f2c6ba31-b94c-411f-9fb5-a3eebb340e1c	00000000-0000-0000-0000-000000000001	21	\N	Pack	Mettre sous emballage	توضيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
39377224-51bf-498e-8200-23382fddfb89	00000000-0000-0000-0000-000000000001	21	\N	Evaluate	Valoriser	تسعير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
25d24616-0d8d-4581-8ed0-435edac62deb	00000000-0000-0000-0000-000000000001	21	\N	cash the money	Encaisser	قبض السعر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e747eb93-820e-4fac-883d-725d058031e7	00000000-0000-0000-0000-000000000001	21	\N	give back the change	Rendre monnaie	رد الفكة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d69b56f9-7641-4b0f-bf41-a59fdbc34851	00000000-0000-0000-0000-000000000001	22	\N	Manage a workstation	Entretenir un poste de travail	إدارة مكان العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2d0bcd11-beec-449c-8d46-52025bfa39b3	00000000-0000-0000-0000-000000000001	22	\N	Follow stock situation	Suivre l'état des stocks	متابعة حركة المخزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a7731da2-dfb9-475f-8103-a2fb5c6f4b8a	00000000-0000-0000-0000-000000000001	22	\N	Detail  supplies	Définir des besoins en approvisionnement	تفنيد الحاجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
edb38b06-01df-45c0-874f-0614f1fc1033	00000000-0000-0000-0000-000000000001	22	\N	Prepare orders	Préparer les commandes	تحضير الطلبات (طلبات المشتريات)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
89a9b93e-a6f1-4c46-b8e2-6f625029c6f2	00000000-0000-0000-0000-000000000001	22	\N	Manage budget	Gerer son budget	ادارة الميزانية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9ef0a863-d39d-4acc-a10b-eb9210593e76	00000000-0000-0000-0000-000000000001	22	\N	Set up cash	Faire la caisse	تنظيم سيولة الصندوق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
db5a4119-a125-4a22-845f-da86fc6a6f51	00000000-0000-0000-0000-000000000001	23	\N	Food hygiene	Hybgiene alimentaire	نظافة الطعام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c4c536a4-e42e-4be8-b9bf-fa2a36953ea2	00000000-0000-0000-0000-000000000001	23	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ffa86c98-1c38-49d5-aada-732e2e7c86bc	00000000-0000-0000-0000-000000000001	23	\N	Clean area	Nettoyer l'espace	تنظيف مساحة العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9f4c701b-58ba-4d7e-8c56-bbb8b05125d9	00000000-0000-0000-0000-000000000001	23	\N	Clean tools	Nettoyer les équipements	تنظيف اواني العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bed2d699-a4b1-4df4-ae29-fcd14acef293	00000000-0000-0000-0000-000000000001	23	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات والأدوات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
10b43001-753d-4c91-81b3-67aafcf62c09	00000000-0000-0000-0000-000000000001	23	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
96301603-727e-4448-9e31-72846d1dd030	00000000-0000-0000-0000-000000000001	24	\N	Keep minimum stock	Maintenir un stock minimum	الحفاظ على  حد ادنى من المخزون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
90d2b53d-8e02-4fd3-8499-6c04e1fcd381	00000000-0000-0000-0000-000000000001	24	\N	Take delivery of raw material	Réceptionner matière premiere	استلام المكونات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
71cc6177-702c-470d-aca7-83e99d453eef	00000000-0000-0000-0000-000000000001	24	\N	Quality control of products	Contrôler la qualité des produits	مراقبة النوعية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
041fc1c7-7215-4c3e-96c4-7ed78cdc5c0f	00000000-0000-0000-0000-000000000001	24	\N	Check daily order	Verifier commande journée	مراقبة الطلبات اليومية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
527d780f-7369-4407-a599-f86c1af5ae79	00000000-0000-0000-0000-000000000001	25	\N	Confectionary - Chocolate	Confiserie - Chocolaterie	الحلويات - مصنع الشوكولاتة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a767cec6-0f1d-4b36-a6ec-48e568abec27	00000000-0000-0000-0000-000000000001	25	\N	Personal education	Education personnelle	المستوى التعليمي المطلوب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4d578364-03be-4fc6-b191-36f5d3d924bc	00000000-0000-0000-0000-000000000001	25	\N	Write	Ecrire	كتابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d824c25e-6301-45aa-bd21-350a9d5548c7	00000000-0000-0000-0000-000000000001	25	\N	Read	Lire	قراءة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f8c9da9c-31ca-4250-97ef-6ed75824c7a7	00000000-0000-0000-0000-000000000001	25	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8fb7878c-ec3a-47a7-96b1-0d6a7def0706	00000000-0000-0000-0000-000000000001	25	\N	Basic confectionary knowledge to position	Connaissances culinaires appropriées	تعاليم الطبخ الاساسية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6a39906c-e310-4f2b-bb5c-bd88abea4db9	00000000-0000-0000-0000-000000000001	15	\N	Melt chocolate	Fondre le chocolat	تذوب الشوكولاته	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f340c193-ae07-4bd7-a774-c31d71840b88	00000000-0000-0000-0000-000000000001	15	\N	Select	Selectioner	اختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
faa22f26-4492-47fa-8a8f-c5f3de59e3b7	00000000-0000-0000-0000-000000000001	15	\N	Grate or shop	Gratter ou briser	خدش أو كسر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
00a9a928-1777-42cb-a86f-946635181259	00000000-0000-0000-0000-000000000001	15	\N	Heat	Rechauffer	تسخين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ceb01af5-6c59-4095-95f5-ca777caa31ce	00000000-0000-0000-0000-000000000001	15	\N	Temper	Temperer	تليين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c21471cc-a57d-4252-b788-ad5689d8b108	00000000-0000-0000-0000-000000000001	15	\N	Stir	Melanger	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1e587e68-f9ec-49c9-b4a5-b231895b7b85	00000000-0000-0000-0000-000000000001	15	\N	Cool	Refroidir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bb24037f-24a3-4a17-9d51-0cfb5d353a93	00000000-0000-0000-0000-000000000001	15	\N	Test	Tester	اختبار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
33e38ef1-ed7d-4dc8-8dcc-16a0d4f144da	00000000-0000-0000-0000-000000000001	26	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
311dfa95-b9a0-4b00-86c2-b64de1c0e847	00000000-0000-0000-0000-000000000001	26	\N	Clean area	Nettoyer l'espace	تنظيف مساحة العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
40e5f663-dac3-4e46-8f98-9495770ae843	00000000-0000-0000-0000-000000000001	26	\N	Clean tools	Nettoyer les équipements	تنظيف اواني العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ee93e375-f631-4479-a1d7-0ce564cd41ca	00000000-0000-0000-0000-000000000001	26	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات والأدوات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
37e51d3f-f00e-46ad-b621-0a4c372067eb	00000000-0000-0000-0000-000000000001	26	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e14ed955-88e8-4a43-86ce-21826c3fcfb7	00000000-0000-0000-0000-000000000001	27	\N	Put sticker	Etiqueter	وضع الملصق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2b42a1e4-5ce3-4d7b-8cb5-08937ec1514d	00000000-0000-0000-0000-000000000001	27	\N	Close	Fermer	أغلق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5be59b67-577f-4764-9695-e46641e85fbf	00000000-0000-0000-0000-000000000001	27	\N	Seal	Sceller	اغلاق محكم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f19e95a7-6784-4404-9439-3d06375052c4	00000000-0000-0000-0000-000000000002	13	\N	Write	Ecrire	كتابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
52526ddb-047c-4b92-8d0e-a7291a27ce49	00000000-0000-0000-0000-000000000002	13	\N	Read	Lire	قراءة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
89349d30-7ec7-41c5-8e69-ae2523d091b1	00000000-0000-0000-0000-000000000002	13	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
82c24af6-c5cc-4a56-b2f7-aaf71e530c86	00000000-0000-0000-0000-000000000002	13	\N	Basic ice cream knowledge to position	Connaissances en glace appropriées	تعاليم الطبخ الاساسية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fb45530a-d711-4b73-9286-7b3679a89a1a	00000000-0000-0000-0000-000000000003	28	\N	Stir	Mélanger	خلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4762078d-3f3d-40dc-be03-7deecc268f09	00000000-0000-0000-0000-000000000002	24	\N	Keep minimum stock	Maintenir un stock minimum	الحفاظ على  حد ادنى من المخزون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
36914ab9-81b6-4f0e-b3e1-0f268cc0e9f0	00000000-0000-0000-0000-000000000002	24	\N	Take delivery of raw material	Réceptionner matière premiere	استلام المكونات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2ea94914-76ba-427e-9bbc-18d4ee9e5774	00000000-0000-0000-0000-000000000002	24	\N	Quality control of products	Contrôler la qualité des produits	مراقبة النوعية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e7e79523-99e2-431f-a396-614beff15e8d	00000000-0000-0000-0000-000000000002	24	\N	Check daily order	Verifier commande journée	مراقبة الطلبات اليومية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
be5ff0e9-bba2-49dd-b429-019151e7f023	00000000-0000-0000-0000-000000000002	15	\N	Add	Additionner	تزويد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
33b1b591-1408-4ca3-9c90-3df731e663e1	00000000-0000-0000-0000-000000000002	15	\N	Count	Compter	عد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5e76824c-7c69-4cda-8d7d-90f00906b9bd	00000000-0000-0000-0000-000000000002	15	\N	Choose	Choisir	اختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bd4fc5b6-0a56-4d40-b35b-c10789b5cb73	00000000-0000-0000-0000-000000000002	15	\N	Itemize	Détailler	التفنيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
94cc94fb-38df-49e0-9613-c5a263efcde2	00000000-0000-0000-0000-000000000002	15	\N	Mix	Mélanger	الخلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f86969d8-6b47-49b7-8a93-c4e1ca454deb	00000000-0000-0000-0000-000000000002	15	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fc3d7fc1-73bb-454d-a3eb-32f27f17fc5e	00000000-0000-0000-0000-000000000002	15	\N	Place	Placer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
efd4ab61-1383-4ca9-83cc-b7f664940970	00000000-0000-0000-0000-000000000002	15	\N	Empty	Vider	افراغ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
07f67a0b-a495-47e0-8239-cee51b2f6a9d	00000000-0000-0000-0000-000000000002	28	\N	Add	Additionner	إضافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3ffed387-340b-449f-b9af-dcd39a03636b	00000000-0000-0000-0000-000000000002	28	\N	Lay	Allonger	بسط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d3264608-214e-4c75-a138-5295d0d58aed	00000000-0000-0000-0000-000000000002	28	\N	Dress	Assaisonner	تتبيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6f7b6d10-ed04-4042-9ace-9a87fa2b599b	00000000-0000-0000-0000-000000000002	28	\N	Soften	Assouplir	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3a96ac9b-4d3e-4e74-9839-ecab592182b3	00000000-0000-0000-0000-000000000002	28	\N	Beat	Battre	خفق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0f5ec0ef-7554-4cd0-8853-1c65194e3f05	00000000-0000-0000-0000-000000000002	28	\N	Dilute	Diluer	تمييع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fb0e92be-67d3-4ba1-95f0-2ebfc2af3fcf	00000000-0000-0000-0000-000000000002	28	\N	Dissolve	Dissoudre	تذويب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6cb7e7cb-76f1-4797-b352-bbdfbfb71c52	00000000-0000-0000-0000-000000000002	28	\N	Fill up	Emplir	ملء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
083afefb-71bc-4cef-bbb7-e85fb20e78e0	00000000-0000-0000-0000-000000000002	28	\N	Emulsify	Émulsionner	استحلاب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
778fe89b-feae-43d4-bcae-f48be671fe3e	00000000-0000-0000-0000-000000000002	28	\N	Ferment	Fermenter	تخمير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
456bb632-f154-4da5-88e5-c9ae74d17b20	00000000-0000-0000-0000-000000000002	28	\N	Stir	Mélanger	خلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b7552017-0f9c-42fe-982c-188524138d82	00000000-0000-0000-0000-000000000002	28	\N	Mix	Mixer	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c24f8551-618a-40da-b4d7-446991ec035f	00000000-0000-0000-0000-000000000002	28	\N	Increase	Monter	زيادة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
96d53cfd-cc5c-4d22-8481-586296070ca1	00000000-0000-0000-0000-000000000002	28	\N	Moisten	Mouiller	تبليل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f61600c3-e129-443f-aa56-775103d1b894	00000000-0000-0000-0000-000000000002	28	\N	Rectify	Rectifier	تصحيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7c664ea9-b9da-4e97-8f80-0bd6e3d95c83	00000000-0000-0000-0000-000000000002	28	\N	Spill	Renverser	تسريب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
81d91a82-d222-4e9a-9ced-a0a6a22d0088	00000000-0000-0000-0000-000000000002	28	\N	Remove	Retirer	اخراج من	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
501fe9df-f89e-414b-83b2-ddebc5fe0b64	00000000-0000-0000-0000-000000000002	28	\N	Sprinkle	Saupoudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f950e74c-93b1-4dd6-b368-36a0a355ec9a	00000000-0000-0000-0000-000000000002	29	\N	Mixing and heating	Mélanger et chauffer ingredients	مزيج المكونات والحرارة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6f69ca98-8158-4cf1-8be8-fc2d29043fcc	00000000-0000-0000-0000-000000000002	29	\N	Pour mix onto a bowl	Verser mélange dans bol	صب الخليط في وعاء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
57b8cea3-e2f6-4fcb-9034-9a068363611a	00000000-0000-0000-0000-000000000002	29	\N	Whisk together by hand	Mélanger le tout  manuellement	خلط كل شيء يدويا	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5a98d80e-dfcc-441c-86ab-a58650e434f0	00000000-0000-0000-0000-000000000002	29	\N	Whisk together by electric motor	Mélanger le tout (moteur electrique)	خلط كل شيء (كهربائيا)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f7451450-1192-4c4e-bc16-054e0c112c5b	00000000-0000-0000-0000-000000000002	29	\N	Add flavor	Ajouter parfum	أضف عطر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f17d762b-ae98-42cd-9ccf-598f45d14371	00000000-0000-0000-0000-000000000002	29	\N	Allow mixture to stand	Reposer le mélange	اراحة الخليط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ff554745-07c5-453b-9f34-906e28487689	00000000-0000-0000-0000-000000000002	29	\N	Pasteurization (burner) manual	Pasteurisation au feu (manuel)	البسترة بالنار (يدوي)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4275e3d6-6d1e-4a1d-ad33-4a041c19d651	00000000-0000-0000-0000-000000000002	29	\N	Pasteurization automatic - machine	Pasteurisation automatique machine	البسترة الاوتوماتيكية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e552ccfc-0b95-4a44-bd73-5358e1662869	00000000-0000-0000-0000-000000000002	29	\N	Chill into refrigerator (manual)	Refroidir au frigo (methode mauelle)	تبريد في الثلاجة (طريقة يدوية)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
802c3e45-96a5-4f46-b3d0-161210ca609b	00000000-0000-0000-0000-000000000002	29	\N	Aging overnight	Laisser reposer pour une nuit	اراحة للية واحدة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
69e27413-9b0a-4f69-adbf-f66e2e6f5fef	00000000-0000-0000-0000-000000000002	29	\N	Pour into ice cream machine container	Verser dans conteneur machine	تصب في حاوية الجهاز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b7fc98e6-9785-4243-baae-7725c0c145d8	00000000-0000-0000-0000-000000000002	29	\N	Churn	Baratter  - Sangler	الهز بقوة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1a4425b1-fb11-425b-848f-c872c824a7b6	00000000-0000-0000-0000-000000000002	29	\N	Harden	Sangler	سرج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
14ef29da-9dc0-4410-9569-5b2750a874c6	00000000-0000-0000-0000-000000000002	29	\N	Empty ice cream from machine	Vider glace de la machine	افراغ الآلة من الثلج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e0c28d54-8dc7-4381-a813-5cc4d87296d9	00000000-0000-0000-0000-000000000002	29	\N	Blast chilling	Faire tomber temperature	انخفاض درجة الحرارة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d9a7ec11-a2d4-4219-b2d0-b1281a9cf577	00000000-0000-0000-0000-000000000002	29	\N	Store in freezer	Stocker au freezer	التخزين  في الثلاجة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0ee39207-9f91-49c1-879f-4ac09ae8d404	00000000-0000-0000-0000-000000000002	30	\N	Check up freezers	Verifier les freezer (s)	فحص الثلاجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0da905af-8158-4c9e-989f-9cc2fb41c442	00000000-0000-0000-0000-000000000002	30	\N	Check up ice cream containers	Verifier apparance conteneurs	فحص حاويات الآيس كريم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
275e50d9-f25c-44e5-a4cd-ce2f9cbee185	00000000-0000-0000-0000-000000000002	30	\N	Keep freezers displays full	Maintenir stock visuel plein	الحفاظ على البضائع بالثلاجات بشكل مرئي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ff9dbcba-8e9b-48cb-b69e-e14842ceccde	00000000-0000-0000-0000-000000000002	30	\N	Check up serving tools	Verifier les outils de service	فحص أدوات التقديم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8cb53f78-04fa-4c3b-873a-17596dcf13fa	00000000-0000-0000-0000-000000000002	30	\N	Greet client	Acceuillir client	استقبال الزبائن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5000bf4f-7731-4473-94b1-bcc09b94f7c0	00000000-0000-0000-0000-000000000002	30	\N	Look after selling point	Entretenir un espace de vente	صيانة نقطة البيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d671083b-e732-4663-81d3-933a9e8d1306	00000000-0000-0000-0000-000000000002	30	\N	Inform client	Renseigner un client	إبلاغ العميل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6661b5c3-9f7e-4c3d-ad70-870678573078	00000000-0000-0000-0000-000000000002	30	\N	Advise	Conseiller	نصيحة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5df81697-759a-4ef9-bb5c-fd119bde2d7c	00000000-0000-0000-0000-000000000002	30	\N	Take order	Prendre la commande des clients	اخذ الطلب من الزبون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
07b84a37-24cd-4d42-a3a4-68cae22132cd	00000000-0000-0000-0000-000000000002	30	\N	Sell products or services	Vendre des produits ou services	بيع المنتجات أو الخدمات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
075e8e0a-0aea-47c2-bb85-6af7395458c8	00000000-0000-0000-0000-000000000002	31	\N	Serve cups	Servir gobelet	تعبئة بالكؤوس	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fa29dbe9-ca50-4de4-98a4-ef053839cee2	00000000-0000-0000-0000-000000000002	31	\N	Serve scope	Servir biscuit	تعبئة بالبسكويت	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ce52f972-8025-48f3-8c81-363cc75ce889	00000000-0000-0000-0000-000000000002	31	\N	Serve by kilo	Servir au kilogramme	تعبئة بالكيلو	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
393036db-fd97-4584-be13-5927bb0192b5	00000000-0000-0000-0000-000000000002	31	\N	Check up paper napkins	Verifier papier serviette	فحص المناديل الورقية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c85d88f2-c477-45b1-bb5c-78f9322f8904	00000000-0000-0000-0000-000000000002	31	\N	Servicing other products	Servir les prduits complementaires	خدمة المنتجات الأخرى	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5731ff9d-e192-4014-9c18-febd5a54d807	00000000-0000-0000-0000-000000000002	31	\N	Do crepes or waffles	Faire des crepes ou waffles	تحضير كريب أو بسكويتات الوفل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
40fbec4c-4e13-4af3-99c5-15880f06c093	00000000-0000-0000-0000-000000000002	31	\N	To do milk shakes	Faire des milk shakes	تحضير milk shakes	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a29c54e4-4cf6-4e2b-97a2-47146af20d44	00000000-0000-0000-0000-000000000002	31	\N	Other mixtures / cocktails	Autres cocktails	مخاليط أخرى / كوكتيلات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
33296af7-eeac-44f6-a4a4-e581adeb6616	00000000-0000-0000-0000-000000000002	31	\N	Fill up order on tray	Preparer plateau commande	تحضير الطلبيات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6e2f6ab0-f3aa-475d-b60a-b59474e213ae	00000000-0000-0000-0000-000000000002	31	\N	To serve order	Servir la commande	تأمين الطلبية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b0e8c9f7-f53e-45c9-9602-e30e74347e18	00000000-0000-0000-0000-000000000002	31	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f91950b0-e3cf-4356-a974-d69efbfcd558	00000000-0000-0000-0000-000000000002	31	\N	Pack	Mettre sous emballage	حزمة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
813dc413-b0bd-4039-bce4-ceb6e8cbbfe9	00000000-0000-0000-0000-000000000002	31	\N	Evaluate	Valoriser	تقييم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
48923d9b-e4ea-4046-9849-8b77c2becc48	00000000-0000-0000-0000-000000000002	31	\N	Cash money	Encaisser	قبض السعر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
df062558-273a-4d2e-9087-d72678edf812	00000000-0000-0000-0000-000000000002	22	\N	Manage a workstation	Entretenir un poste de travail	إدارة مكان العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9b54f6a7-7325-4b56-98e6-32f7c8f3f0a0	00000000-0000-0000-0000-000000000002	22	\N	Follow stock situation	Suivre l'état des stocks	متابعة حركة المخزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7b5a707d-a515-4175-8a7d-09da87034090	00000000-0000-0000-0000-000000000002	22	\N	Detail  supplies	Définir des besoins en approvisionnement	تفنيد الحاجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7b44ae7b-9fbd-48e5-b872-4be2685dee5e	00000000-0000-0000-0000-000000000002	22	\N	Prepare orders	Préparer les commandes	تحضير الطلبات (طلبات المشتريات)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
aec121c0-a8d1-4f91-a5dd-7590b1e45b9c	00000000-0000-0000-0000-000000000002	22	\N	Manage budget	Gerer son budget	ادارة الميزانية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
386d9b5a-1220-4121-b3df-01e145e71566	00000000-0000-0000-0000-000000000002	22	\N	Set up cash	Faire la caisse	تنظيم سيولة الصندوق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
da58e1ee-7324-4e8b-91a5-5b62a92b7b4f	00000000-0000-0000-0000-000000000002	23	\N	Food hygiene	Hybgiene alimentaire	نظافة الطعام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5f1efc2a-d477-4234-9dfb-f2bbb9579a91	00000000-0000-0000-0000-000000000002	23	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
11739645-8215-4889-8cfe-c6eccbeaa9c6	00000000-0000-0000-0000-000000000002	23	\N	Clean area	Nettoyer l'espace	تنظيف مكان العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
80480cf2-aa3f-4b5e-9bdd-6fc2c2430fbc	00000000-0000-0000-0000-000000000002	23	\N	Clean tools	Nettoyer les équipements	تنظيف المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9a809e7c-1379-4594-900f-da7158244098	00000000-0000-0000-0000-000000000002	23	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
164610c1-4de1-427c-ae67-6a81950b0314	00000000-0000-0000-0000-000000000002	23	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a1456689-ee73-4dc6-b59c-4d7b56cf23c2	00000000-0000-0000-0000-000000000003	13	\N	Write	Ecrire	كتابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d4568582-6e47-4eff-a21d-838d2cb6316d	00000000-0000-0000-0000-000000000003	13	\N	Read	Lire	قراءة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5ea8f03f-b153-4b35-a039-27af1812b572	00000000-0000-0000-0000-000000000003	13	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1e496c96-3999-4eee-93c2-d6944dd641e5	00000000-0000-0000-0000-000000000003	13	\N	Basic cooking knowledge to position	Connaissances culinaires appropriées	تعاليم الطبخ الاساسية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
74be697f-8ed3-46c4-aadd-9d8b1d76cd4c	00000000-0000-0000-0000-000000000003	24	\N	Keep minimum stock	Maintenir un stock minimum	الحفاظ على  حد ادنى من المخزون	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f696b8fc-6554-41c4-8bee-7494261fa794	00000000-0000-0000-0000-000000000003	24	\N	Take delivery of raw material	Réceptionner matière premiere	استلام المكونات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
50001b6b-3830-4975-b241-9d5149d6ef3c	00000000-0000-0000-0000-000000000003	24	\N	Quality control of products	Contrôler la qualité des produits	مراقبة النوعية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
82a8f2f0-9bdb-4dc9-a917-d40c2e4e8bfc	00000000-0000-0000-0000-000000000003	24	\N	Check daily order	Verifier commande journée	مراقبة الطلبات اليومية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
124a6c93-87e6-4d1a-95e9-ddccc64a7d05	00000000-0000-0000-0000-000000000003	32	\N	Set up	Mise en place	التنظيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1c0c582f-143e-409b-899c-ec13a29b8530	00000000-0000-0000-0000-000000000003	32	\N	Add	Additionner	التزويد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4d0fed30-95bd-4f80-89a8-eba5620ffc46	00000000-0000-0000-0000-000000000003	32	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f02526fe-a22c-4a4d-81e5-f0d70f523052	00000000-0000-0000-0000-000000000003	32	\N	Choose	Choisir	الاختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
73baed07-321a-4f1e-b157-669730841cea	00000000-0000-0000-0000-000000000003	32	\N	Itemize	Détailler	التفنيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
04617382-75bb-45e1-9068-1e486f418c54	00000000-0000-0000-0000-000000000003	32	\N	Mix	Mélanger	الخلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3d3a35ca-574e-4498-b804-f6a823596fd7	00000000-0000-0000-0000-000000000003	32	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1a75aa48-c5a4-4890-b502-c20ef4b19507	00000000-0000-0000-0000-000000000003	32	\N	Place	Placer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4f2587f2-ffd9-43a2-94d3-fda939b2db80	00000000-0000-0000-0000-000000000003	32	\N	Empty	Vider	افراغ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
23b5530d-5e04-4a85-a3c1-49ce9a7bb8ee	00000000-0000-0000-0000-000000000003	28	\N	Add	Additionner	إضافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
884841a8-25b6-4127-b0b5-024406c27a5d	00000000-0000-0000-0000-000000000003	28	\N	Combine yeast	Ajouter levure	وضع الخميرة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
cb18e5fe-cf21-4c93-8d44-4b1c939ba67a	00000000-0000-0000-0000-000000000003	28	\N	Lay	Allonger	بسط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
773d1e85-8ac6-4e0e-8a9a-1cd8af69ae0b	00000000-0000-0000-0000-000000000003	28	\N	Dress	Assaisonner	تتبيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
005efd11-f76f-40bc-aa9f-ff3d84bfe2d1	00000000-0000-0000-0000-000000000003	28	\N	Soften	Assouplir	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
36728579-5842-4fb3-9e43-edd90cc08df9	00000000-0000-0000-0000-000000000003	28	\N	Beat	Battre	خفق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6a18c664-b262-417f-9136-361a5f5ea004	00000000-0000-0000-0000-000000000003	28	\N	Dilute	Diluer	تمييع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5b7526ca-a9a6-4912-8e7c-3efba9362d78	00000000-0000-0000-0000-000000000003	28	\N	Dissolve	Dissoudre	تذويب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
173ae9df-af7a-4f19-807e-e62365592475	00000000-0000-0000-0000-000000000003	28	\N	Fill up	Emplir	ملء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c3815c3b-73ff-4488-812b-266f0f2e7a4e	00000000-0000-0000-0000-000000000003	28	\N	Emulsify	Émulsionner	استحلاب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c44690f1-ac3d-4658-a064-45abeef197a5	00000000-0000-0000-0000-000000000003	28	\N	Ferment	Fermenter	تخمير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
726082a5-78dd-491c-ad9b-4193f67bacec	00000000-0000-0000-0000-000000000003	28	\N	Mix	Mixer	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4d5a7b2b-9e9c-4761-a052-1dda5467150f	00000000-0000-0000-0000-000000000003	28	\N	Increase	Monter	زيادة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d66bee2b-7a31-4ed9-89bc-b4d1c51cfba6	00000000-0000-0000-0000-000000000003	28	\N	Moisten	Mouiller	تبليل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dbe8e556-37d8-4981-b248-06d0530a27c2	00000000-0000-0000-0000-000000000003	28	\N	Rectify	Rectifier	تصحيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
13d22b7c-8bd6-4876-9ceb-9baff4152a74	00000000-0000-0000-0000-000000000003	28	\N	Spill	Renverser	تسريب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4d87ddf6-a2e2-47cb-8724-c1a04b891290	00000000-0000-0000-0000-000000000003	28	\N	Remove	Retirer	إزالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c40e69f9-bdf0-4532-bbcb-288d361fc73a	00000000-0000-0000-0000-000000000003	28	\N	Sprinkle	Saupoudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
92f54406-8519-455e-83a4-019531cc1224	00000000-0000-0000-0000-000000000003	33	\N	Mix	Mélanger	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
aaaa1515-bab8-49ab-b606-da5a2fb2d9a9	00000000-0000-0000-0000-000000000003	33	\N	Cut	Decouper	تقطيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
42dbc9ce-19cf-4bbb-92de-1412be336be5	00000000-0000-0000-0000-000000000003	33	\N	Spread	Étaler	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
39dee73b-cb41-4108-b45e-3ae033611a21	00000000-0000-0000-0000-000000000003	33	\N	Lay down	Étendre	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
731d63c6-78b9-4dae-84f2-16a7240f143e	00000000-0000-0000-0000-000000000003	33	\N	Shape	Façonner	تشكيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bfd34bf2-39e6-4efc-b65a-3af6f2e2fd7a	00000000-0000-0000-0000-000000000003	33	\N	Stuff	Farcir	حشي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a2238841-605c-4420-bd8d-1a3bcb4fe242	00000000-0000-0000-0000-000000000003	33	\N	Flour	Fariner	طحين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a30a3b83-6692-4900-8196-b86c71799bd7	00000000-0000-0000-0000-000000000003	33	\N	Refold	rabattre	إمالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c23ea9dd-6892-43c1-bafd-21eabc052e24	00000000-0000-0000-0000-000000000003	33	\N	Sieve	tamiser	غربال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2b5c97c0-73bf-40e8-aa28-fc98cb659e46	00000000-0000-0000-0000-000000000003	33	\N	Pour	Verser	سكب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ae8dcafd-03a9-4dec-8f34-e1650fbf59ff	00000000-0000-0000-0000-000000000003	34	\N	Let stand	Reposer	اراحة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
edcd977c-c531-4ecb-83f1-9865e96c0fba	00000000-0000-0000-0000-000000000003	34	\N	Mould	Mouler / faconner	قالب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e3acb99b-97b4-46c8-ab3f-a1ab7747ddb6	00000000-0000-0000-0000-000000000003	34	\N	Add	Ajouter	إضافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e855bdf4-a0ec-482f-82b2-a879a82e6e4e	00000000-0000-0000-0000-000000000003	34	\N	Stretch	Allonger	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bde313aa-5711-4500-80f1-30b222acc6c4	00000000-0000-0000-0000-000000000003	34	\N	Bring	Amener	احضار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bf92ac9f-7c4e-4432-8791-9571edee81d5	00000000-0000-0000-0000-000000000003	34	\N	Flatten	Aplatir	تسطيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c17160c5-a7a2-4dba-9e6a-87d4ea8855f4	00000000-0000-0000-0000-000000000003	34	\N	Soften	Assouplir	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f1e6927c-74c0-438c-ac06-86ee0dbba457	00000000-0000-0000-0000-000000000003	34	\N	Butter	Beurrer	زبدة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b837bb8e-fed0-4d94-b2cc-6838c80dd8ee	00000000-0000-0000-0000-000000000003	34	\N	Coat	Chemiser	معطف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9b3f5b60-79a5-4fcc-92e6-ae07a946d0bc	00000000-0000-0000-0000-000000000003	34	\N	Choose	Choisir	أختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
90ded60a-f3b6-4d91-967a-70895e4d911c	00000000-0000-0000-0000-000000000003	34	\N	Complete	Compléter	اكمال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
681ff20e-9933-4d75-8591-03404b931179	00000000-0000-0000-0000-000000000003	34	\N	Cut	Couper	تقطيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b64adc8e-0cdd-4d44-a61b-8345dfbe3374	00000000-0000-0000-0000-000000000003	34	\N	Cover	Couvrir	التغطية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1638aa2d-0ad8-4951-a45f-b8fb098118bb	00000000-0000-0000-0000-000000000003	34	\N	Thaw	Decongeler	اذابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bd489fe7-fd6c-4f8b-a3bf-2a6690968bcf	00000000-0000-0000-0000-000000000003	34	\N	Dress up	Dresser	تزيين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
cce2a154-8a19-491d-9f10-9ea5223e0cdb	00000000-0000-0000-0000-000000000003	34	\N	Fill	Emplir	ملء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7640240b-b2e6-40da-801b-9469a3199d73	00000000-0000-0000-0000-000000000003	34	\N	Store	Entreposer	حفظ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0ab8beb4-7eb8-4468-95fa-823e4b7fb707	00000000-0000-0000-0000-000000000003	34	\N	Wrap	Envelopper	لف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
462434f9-7d39-4e83-bbd2-dd2f07839922	00000000-0000-0000-0000-000000000003	34	\N	Spread	Étendre	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
49f4bd28-2d63-492b-8646-7fb43172aaff	00000000-0000-0000-0000-000000000003	34	\N	Sweat	Étuver	تبخير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
78e69688-1a23-48a4-ae78-b457b8dccbb9	00000000-0000-0000-0000-000000000003	34	\N	Shape	Façonner	اعطاء شكل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
53f5cee7-183f-4b8e-b2f2-273af065475d	00000000-0000-0000-0000-000000000003	34	\N	Stuff	Farcir	حشي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
79680df7-8efd-4445-92a5-8531cd5ed94e	00000000-0000-0000-0000-000000000003	34	\N	Flour	Fariner	طحين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
89330a6f-698c-46f7-a259-e17894df0a36	00000000-0000-0000-0000-000000000003	34	\N	Soak	Imbiber	نقع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bd41797b-72da-4723-9f3c-f818b7e7d3b1	00000000-0000-0000-0000-000000000003	34	\N	Incorporate	Incorporer	دمج او تجسيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d395acf5-69ab-42ac-9842-12504ba79aea	00000000-0000-0000-0000-000000000003	34	\N	Raise dough	Lever la pate	رفع العجين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b481d209-fce8-4994-8d06-a95c95bf5d3d	00000000-0000-0000-0000-000000000003	34	\N	Roll	Laminer	تدحرج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3e15e92a-5c87-4220-aba0-f77f4f81b23a	00000000-0000-0000-0000-000000000003	34	\N	Catch	Pincer	قرص	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
cfcd9c04-51a2-49a9-9af4-9de01c8d1eaa	00000000-0000-0000-0000-000000000003	34	\N	Fold	Plier	طي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
527ed95b-2212-4ecd-acff-d79a2aea8894	00000000-0000-0000-0000-000000000003	34	\N	Spray	Poudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f08fa4cc-6ac0-4b85-b4fe-16d352d62647	00000000-0000-0000-0000-000000000003	34	\N	Protect	Protéger	حماية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dc8ba64e-48d9-4a6a-85dc-8ba2650108a5	00000000-0000-0000-0000-000000000003	34	\N	Refold	Rabattre	امالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1853dce4-23b1-4057-a6a5-38b1eb06d5aa	00000000-0000-0000-0000-000000000003	34	\N	raise taste	Relever	رفع الطعم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
586f4614-4e43-4ada-bdd9-a6c2c2737c0c	00000000-0000-0000-0000-000000000003	34	\N	Pour	Renverser	صب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7e8b0c2e-78e0-4a0a-9d99-d69d115c9359	00000000-0000-0000-0000-000000000003	34	\N	Sit dough	Reposer	اراحة العجين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bd27b930-c86c-4cb7-bfa0-0c02866bd500	00000000-0000-0000-0000-000000000003	34	\N	Remove	Retirer	اخراج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
64fe5498-d87a-473e-b3ed-771e89bf9753	00000000-0000-0000-0000-000000000003	34	\N	Sprinkle	Saupoudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5e99f8ee-4a19-4aaf-975b-8c1673e08fc1	00000000-0000-0000-0000-000000000003	35	\N	Shine	Faire briller	تلميع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
81f975f0-e0ef-4b99-b419-99ce1b04c284	00000000-0000-0000-0000-000000000003	35	\N	Warm up	Chauffer	الاحماء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9225324d-82da-4f20-9d75-b60ad8b5b9d9	00000000-0000-0000-0000-000000000003	35	\N	Complete	Compléter	اكمال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b2c89e2f-f462-4b55-8c65-f28190f32d63	00000000-0000-0000-0000-000000000003	35	\N	Get rid of	Débarrasser	ازالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
eb6eee08-7836-4728-81d7-040d4d8a3d01	00000000-0000-0000-0000-000000000003	35	\N	Dry	Dessécher	تجفيف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bea31ac3-0080-483b-8044-1037f6e60a4b	00000000-0000-0000-0000-000000000003	35	\N	lock	Enfermer	قفل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
cf2eeec2-8d01-4476-acbb-6d4fa33a5476	00000000-0000-0000-0000-000000000003	35	\N	Put into oven	Enfourner	وضع في الفرن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bc7ad319-8815-4ae4-bf61-f1b5e5641eb8	00000000-0000-0000-0000-000000000003	35	\N	Drop	Faire tomber	انخفاض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5810a0f6-d852-455b-81eb-d0ad232269e4	00000000-0000-0000-0000-000000000003	35	\N	Put	Mettre	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d12993d0-4afe-4302-9945-ae7112a55e99	00000000-0000-0000-0000-000000000003	35	\N	Follow on	Poursuivre	متابعة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
44fcb91b-bf28-486d-9ccc-a191d5a8281a	00000000-0000-0000-0000-000000000003	35	\N	Spread	Répartir	توزيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
43fe1a9f-b69d-4bb3-8bfd-b5e443b7eb07	00000000-0000-0000-0000-000000000003	35	\N	Rest	Reposer	اراحة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2f7a1251-c86b-42de-bff8-48a516307a6d	00000000-0000-0000-0000-000000000003	35	\N	Take off	Retirer	خلع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
86698d0a-9315-4351-bcf9-8d2c14c60072	00000000-0000-0000-0000-000000000003	35	\N	roll over	Retourner	برم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6d2d0d2d-9480-480d-9a5c-f2bc4ad2862b	00000000-0000-0000-0000-000000000003	35	\N	Brown	Saisir	أسمر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5200ebeb-13b4-40fd-8cdd-89c8c439bde9	00000000-0000-0000-0000-000000000003	35	\N	Finish cooking	Terminer	الانتهاء من الطبخ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b1d30365-2fab-463c-a541-c871f4e6f0de	00000000-0000-0000-0000-000000000003	35	\N	Cool down	Tiédir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2189ff46-1aa2-48f7-9c1b-595aa0d9ee5f	00000000-0000-0000-0000-000000000003	35	\N	Sort out	Trier	فرز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
12023c28-4903-472c-9086-0b55f8617b9c	00000000-0000-0000-0000-000000000003	35	\N	Empty	Vider	افراغ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b89722f4-8a66-47df-88e6-60944f871fc4	00000000-0000-0000-0000-000000000003	36	\N	Finalize	Finaliser	وضع اللمسات الأخيرة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6c0d699e-4fd8-4865-b6e8-a88747b3cb18	00000000-0000-0000-0000-000000000003	36	\N	Flavor	Aromatiser	نكهة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1182adaa-3f83-4f61-b923-6b64c2c63582	00000000-0000-0000-0000-000000000003	36	\N	Whip cream	battre de la crème	خبط الكريم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
eb3365d0-38dc-4f28-8fa6-f172af6a0a58	00000000-0000-0000-0000-000000000003	36	\N	Boil	Bouillir	دمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9926311e-561a-4681-9047-43043f3aad54	00000000-0000-0000-0000-000000000003	36	\N	Warm	Chauffer	تسخين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b0251a4d-eea3-4daf-8765-143faa54688f	00000000-0000-0000-0000-000000000003	36	\N	Stick	Coller	لصق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a567e49a-f9e4-438f-ab5e-5eabac5c0a51	00000000-0000-0000-0000-000000000003	36	\N	Color	Colorer	تلوين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2f373e80-bbad-42a2-9e2f-f66d4d64566f	00000000-0000-0000-0000-000000000003	36	\N	Crush	Concasser	طحن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5c142fc3-bcec-4597-a84b-5f6ce784b592	00000000-0000-0000-0000-000000000003	36	\N	Coat	Couvrir	تغطية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
21ae459e-2e52-46c0-9def-ef36dfa91b03	00000000-0000-0000-0000-000000000003	36	\N	Pastry cone	Cornet a patisserie	المعجنات مع كورنيت	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
51938600-c805-4127-86b8-dbeab405115d	00000000-0000-0000-0000-000000000003	36	\N	Dilute	Délayer	ترقيق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b6922fdd-5f67-4cb2-b2e8-cf15af8873a1	00000000-0000-0000-0000-000000000003	36	\N	Stone	Dénoyauter	ازالة العجو	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4d536e13-c834-4e30-9330-66717d2a1d08	00000000-0000-0000-0000-000000000003	36	\N	Itemize	Détailler	فصل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5500b573-6588-4974-b933-7cfddc236101	00000000-0000-0000-0000-000000000003	36	\N	Dissolve	Dissoudre	تذويب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b5e69bdc-3fa3-4b94-8ef5-281f4a66e944	00000000-0000-0000-0000-000000000003	36	\N	Slice	Émincer	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b92a17b4-3191-41a3-b746-3ecf58c0396f	00000000-0000-0000-0000-000000000003	36	\N	Emulsify	Émulsionner	استحلاب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9952ce7e-522f-4b83-bda3-9b2b01adb18f	00000000-0000-0000-0000-000000000003	36	\N	Dessed	Épépiner	ازالة البذر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
872d8a14-ffd4-4697-b419-4e677341e59e	00000000-0000-0000-0000-000000000003	36	\N	Hull	Équeuter	إزالة الهيكل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
949629ca-7c88-4a9a-a964-732196b2e990	00000000-0000-0000-0000-000000000003	36	\N	Wring	Essorer	أقحام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
320c5646-481c-4a03-bdc9-f4ab05037452	00000000-0000-0000-0000-000000000003	36	\N	Spread	Étaler	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a685776c-ba90-4d8c-b3ab-49bbde673a33	00000000-0000-0000-0000-000000000003	36	\N	Beat	Fouetter	خبط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
36b02f08-0783-48b3-b3f2-bd8d2ddf784a	00000000-0000-0000-0000-000000000003	36	\N	Candy	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
31ea94d3-9576-4667-943c-a51276d58148	00000000-0000-0000-0000-000000000003	36	\N	Chill	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f47caa82-ac9f-4444-a73a-6445603984ff	00000000-0000-0000-0000-000000000003	36	\N	Macerate	Macérer	نهك	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a701e4c1-fee5-4fec-88e7-240be5c2e34f	00000000-0000-0000-0000-000000000003	36	\N	Soak	Mouiller	ترطيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c46f7501-4216-4348-87da-7673ba847b8b	00000000-0000-0000-0000-000000000003	36	\N	Expose	Présenter	تقديم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ddd15ebe-213e-4303-87d0-323c6908516a	00000000-0000-0000-0000-000000000003	36	\N	Rectify	Rectifier	تصحيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c8c6473b-4c8b-45e1-890d-e50a4ed96513	00000000-0000-0000-0000-000000000003	36	\N	Turn onto	Retourner	قلب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c7acc9b8-4729-49df-9e0c-063f36837da9	00000000-0000-0000-0000-000000000003	36	\N	Split	Séparer	فصل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bfd11416-3212-4ce5-9962-9d00167c149b	00000000-0000-0000-0000-000000000003	19	\N	Prepare package	Préparer emballage	تحضير التغليف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
53dbf8a1-98fb-4991-a346-8481101f68ce	00000000-0000-0000-0000-000000000003	19	\N	Open	Ouvrir	فتح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
12e5974f-3e7d-4057-a98e-e51933e1f900	00000000-0000-0000-0000-000000000003	19	\N	Slide	Glisser	انزلاق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1054d713-bd15-4545-988d-4fc249eed707	00000000-0000-0000-0000-000000000003	19	\N	Wrap	Empaquetter	توضيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
84dfdb7d-2d8f-405c-999e-08f9d6c22bda	00000000-0000-0000-0000-000000000003	19	\N	Put sticker	Etiqueter	وضع العلامات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
491dd8f8-f88e-45ca-9bee-5b7b2d196ccd	00000000-0000-0000-0000-000000000003	19	\N	Close	Fermer	اقفال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e0797b12-9c57-4599-931b-372ffbc60ba2	00000000-0000-0000-0000-000000000003	19	\N	Seal	Sceller	ختم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
474f5b55-2348-4b48-8e2e-3e173b74e6b1	00000000-0000-0000-0000-000000000003	37	\N	Prepare showcase	Préparer etalage	تحضير العرض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
eab9b00d-6be4-4db0-9836-f1dff88bb12a	00000000-0000-0000-0000-000000000003	37	\N	Arrange	Disposer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
93848e63-5354-479a-a050-8949add0c942	00000000-0000-0000-0000-000000000003	37	\N	Price	Mettre les prix	وضع الأسعار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ff48ee2a-d7d0-4be0-b07f-9002ff9f2363	00000000-0000-0000-0000-000000000003	37	\N	Protect	Proteger	حماية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
acc6e165-768b-4882-89c6-6361c0a3c94c	00000000-0000-0000-0000-000000000003	38	\N	Greet client	Acceuillir client	استقبال الزبائن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b7e2a16b-0f0d-463a-b2c2-fa2993d6dc7c	00000000-0000-0000-0000-000000000003	38	\N	Advise	Conseiller	اعطاء نصائح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
34580f0f-ec01-4b34-ad24-db8f6bcf6bad	00000000-0000-0000-0000-000000000003	38	\N	Close sale	Finaliser vente	الانتهاء من البيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
268cd74a-bc7a-4fea-8282-6f286febb453	00000000-0000-0000-0000-000000000003	38	\N	Perceive amount	Encaisser	قبض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8854f6ea-ba0d-4d1b-9058-147ef17dd9f4	00000000-0000-0000-0000-000000000003	38	\N	Give back	Rendre monnaie	اعادة الفكة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7a7fab97-8d75-4903-ab6a-d48f02e69f3c	00000000-0000-0000-0000-000000000003	22	\N	Manage a workstation	Entretenir un poste de travail	إدارة مكان العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e644e850-745a-4c00-98cc-1c8c88e75652	00000000-0000-0000-0000-000000000003	22	\N	Follow stock situation	Suivre l'état des stocks	متابعة حركة المخزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a6d79885-ad38-4a37-a9d9-faf425476dc3	00000000-0000-0000-0000-000000000003	22	\N	Detail  supplies	Définir des besoins en approvisionnement	تفنيد الحاجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e4ba9c2c-945e-4502-8da4-47d9c2fefb38	00000000-0000-0000-0000-000000000003	22	\N	Prepare orders	Préparer les commandes	تحضير الطلبات (طلبات المشتريات)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e71cc75c-13e8-4e42-9cba-122b1dac4f92	00000000-0000-0000-0000-000000000003	22	\N	Manage budget	Gerer son budget	ادارة الميزانية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
be6356ad-5aa1-415a-855e-f589c2daf110	00000000-0000-0000-0000-000000000003	22	\N	Set up cash	Faire la caisse	تنظيم سيولة الصندوق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4e64fa79-aa97-4fdd-acaa-96246e07bbc6	00000000-0000-0000-0000-000000000003	23	\N	Food hygiene	Hybgiene alimentaire	نظافة الطعام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
075dceeb-824b-4dd5-b36d-22439cdcacc2	00000000-0000-0000-0000-000000000003	23	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e8ee8878-d9ce-4989-95b0-0ea9ccd2c20a	00000000-0000-0000-0000-000000000003	23	\N	Clean area	Nettoyer l'espace	تنظيف مساحة العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
cd720d62-0c42-4aa1-879f-865ba0ac4a61	00000000-0000-0000-0000-000000000003	23	\N	Clean tools	Nettoyer les équipements	تنظيف اواني العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3be8c7f5-f80f-4813-b9d1-ffd1e81c982a	00000000-0000-0000-0000-000000000003	41	\N	Raise dough	Lever la pate	رفع العجين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
12ec6081-17ef-466b-8a36-aceed0a8f40c	00000000-0000-0000-0000-000000000003	23	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات والأدوات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
403c93d5-ada6-40e4-91b0-868dad813044	00000000-0000-0000-0000-000000000003	23	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f0704eb5-98f1-4972-b242-94f0ad6f3bba	00000000-0000-0000-0000-000000000003	24	\N	Preparation	Preparation	التحضير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fe79fe8d-1b76-4546-9ef5-2341c40a516f	00000000-0000-0000-0000-000000000003	24	\N	Set up	Mise en place	التنظيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
518b0620-03d6-4115-b57b-523d50dd3744	00000000-0000-0000-0000-000000000003	24	\N	Add	Additionner	التزويد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
619dbf9e-5ebd-43e6-b796-63e7db4037f3	00000000-0000-0000-0000-000000000003	24	\N	Count	Compter	العد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e584e84c-e8ba-40ea-8fa9-b2526e1f4d7b	00000000-0000-0000-0000-000000000003	24	\N	Choose	Choisir	الاختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
194a9f58-ebf8-48d1-9dc3-69a866e9cf55	00000000-0000-0000-0000-000000000003	24	\N	Itemize	Détailler	التفنيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f5be434f-16cb-47f4-ae0e-b6cc67815b30	00000000-0000-0000-0000-000000000003	24	\N	Mix	Mélanger	الخلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
646aca0b-564f-4410-a6b6-383dfb3b8f12	00000000-0000-0000-0000-000000000003	24	\N	Weigh	Peser	وزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9deb40f9-cb4b-43bd-9c6c-68b6f1b33744	00000000-0000-0000-0000-000000000003	24	\N	Place	Placer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
531543ca-7a31-423c-b84b-4fdf5fc6e1ef	00000000-0000-0000-0000-000000000003	39	\N	Prepare dough	Preparer appareil	تحضير العجين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dfdb8220-bf81-4970-b92d-276a46f30f2a	00000000-0000-0000-0000-000000000003	39	\N	Add	Additionner	إضافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
373edbec-cf27-44c6-bdb5-760fac3c4d95	00000000-0000-0000-0000-000000000003	39	\N	Combine yeast	Ajouter levure	وضع الخميرة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a5f29a8a-84d3-4a17-b3f9-83ad88f7aacb	00000000-0000-0000-0000-000000000003	39	\N	Lay	Allonger	بسط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1147d0ac-cf56-4af2-a1a6-e22c1b6924a4	00000000-0000-0000-0000-000000000003	39	\N	Dress	Assaisonner	تتبيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
90a9f83d-59c4-473c-b847-d1b92e8fd894	00000000-0000-0000-0000-000000000003	39	\N	Soften	Assouplir	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e1c9ffd7-1605-45c1-9dd4-5c61b7105f68	00000000-0000-0000-0000-000000000003	39	\N	Beat	Battre	خفق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
980fcaa8-4dce-4353-83bc-b4e387fa0de9	00000000-0000-0000-0000-000000000003	39	\N	Dilute	Diluer	تمييع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8376d443-d43f-41b3-b038-5b41825d43b6	00000000-0000-0000-0000-000000000003	39	\N	Dissolve	Dissoudre	تذويب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
71abd243-6b8b-4e8a-b57d-df1416e8bf61	00000000-0000-0000-0000-000000000003	39	\N	Fill up	Emplir	ملء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5bd80f6f-c1e7-41b5-8f90-9304cb634e77	00000000-0000-0000-0000-000000000003	39	\N	Emulsify	Émulsionner	استحلاب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
00f81c31-e54a-4388-9d99-b2d9019b2a1c	00000000-0000-0000-0000-000000000003	39	\N	Ferment	Fermenter	تخمير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7a281159-aff0-42f2-a00e-577d7c05f1ec	00000000-0000-0000-0000-000000000003	39	\N	Stir	Mélanger	خلط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c968f18a-586e-41d6-b75e-910c2f29714a	00000000-0000-0000-0000-000000000003	39	\N	Mix	Mixer	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
96d01bf8-a977-4487-91e5-d71ff4454d11	00000000-0000-0000-0000-000000000003	39	\N	Increase	Monter	زيادة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
58c62667-b3bd-4cd3-bd0a-dfc92a7c9301	00000000-0000-0000-0000-000000000003	39	\N	Moisten	Mouiller	تبليل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
619b1fa6-28e2-42b5-99f1-67c64c3f45bc	00000000-0000-0000-0000-000000000003	39	\N	Rectify	Rectifier	تصحيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d1e4db37-5a24-42ca-95f5-fa1a7645162d	00000000-0000-0000-0000-000000000003	39	\N	Spill	Renverser	تسريب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e92e0d31-2ded-40b1-8776-a212c57dd04c	00000000-0000-0000-0000-000000000003	39	\N	Remove	Retirer	إزالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3aa178a2-078f-4a09-afe3-ce3e1dc72afe	00000000-0000-0000-0000-000000000003	40	\N	Prepare [Danish]	Préparer les pieces [viennoiseries]	تحضير [دانماركي]	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
adf294e9-ea01-43f5-873e-aba6392d9e61	00000000-0000-0000-0000-000000000003	40	\N	Mix	Mélanger	مزج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7ad4b4d3-5958-46c0-b54b-6f81d89cb2ad	00000000-0000-0000-0000-000000000003	40	\N	Cut	Decouper	تقطيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6b917be4-1c06-4217-9134-c0d806db42f2	00000000-0000-0000-0000-000000000003	40	\N	Spread	Étaler	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
83ef8714-7e52-44cf-9145-e891d058b7e5	00000000-0000-0000-0000-000000000003	40	\N	Lay down	Étendre	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ed663b5b-c7f1-4b26-a4ab-2f3c3baa0789	00000000-0000-0000-0000-000000000003	40	\N	Shape	Façonner	تشكيل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2d0978ab-9302-46a1-b32f-ec74b7202106	00000000-0000-0000-0000-000000000003	40	\N	Stuff	Farcir	حشي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
72f80da9-dbec-4bc3-8157-d86ddf3be197	00000000-0000-0000-0000-000000000003	40	\N	Flour	Fariner	طحين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4a73058b-3392-45d7-9fa1-215e412643db	00000000-0000-0000-0000-000000000003	40	\N	Refold	rabattre	إمالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6189465d-1539-4662-ac4c-4ca05895b8ca	00000000-0000-0000-0000-000000000003	40	\N	Sieve	tamiser	غربال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1577000b-b1a9-414b-bdd2-4759a3c062a1	00000000-0000-0000-0000-000000000003	41	\N	Produce	Produire	إنتاج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d33ca546-f779-448d-9813-cf30925ac543	00000000-0000-0000-0000-000000000003	41	\N	Let stand	Reposer	اراحة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
80089617-1462-4fc2-97d1-3fdc7a1c45c4	00000000-0000-0000-0000-000000000003	41	\N	Mould	Mouler / faconner	قالب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bcdb602f-3adc-400d-9c64-4d40679ae63b	00000000-0000-0000-0000-000000000003	41	\N	Add	Ajouter	إضافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3cf3992e-60f2-4775-b398-5c02586f8c73	00000000-0000-0000-0000-000000000003	41	\N	Stretch	Allonger	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
60d46bc0-f37a-4626-bfd9-a561a92f2d4f	00000000-0000-0000-0000-000000000003	41	\N	Bring	Amener	احضار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f7f265ac-9ac4-403b-9004-4dc73e6584cc	00000000-0000-0000-0000-000000000003	41	\N	Flatten	Aplatir	تسطيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
068c76d5-8134-4b96-9b69-e03911b2b45f	00000000-0000-0000-0000-000000000003	41	\N	Soften	Assouplir	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
871a4fb6-3029-44ac-b870-2114e7ca36d2	00000000-0000-0000-0000-000000000003	41	\N	Butter	Beurrer	زبدة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2326c028-3b42-45fe-83c3-f12c82a1170c	00000000-0000-0000-0000-000000000003	41	\N	Coat	Chemiser	معطف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
67af8f24-d446-4afb-ba6b-e761b31d79b4	00000000-0000-0000-0000-000000000003	41	\N	Choose	Choisir	أختيار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
80e0ba54-29fa-46bb-8f9a-c565d1195eeb	00000000-0000-0000-0000-000000000003	41	\N	Complete	Compléter	اكمال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a3f551b8-b62c-401c-929b-0fdac3e8e175	00000000-0000-0000-0000-000000000003	41	\N	Cut	Couper	تقطيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
bad133ff-aa7b-4c17-8e15-18409eb06f7c	00000000-0000-0000-0000-000000000003	41	\N	Cover	Couvrir	التغطية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
84ca4261-45d3-4832-aa50-e7bba0ac355c	00000000-0000-0000-0000-000000000003	41	\N	Thaw	Decongeler	اذابة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
21bc8ca8-ff21-488f-9c2d-d99a1e460ebe	00000000-0000-0000-0000-000000000003	41	\N	Dress up	Dresser	تزيين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5c87c57f-fe2a-435d-9476-3e5f1f380ebf	00000000-0000-0000-0000-000000000003	41	\N	Fill	Emplir	ملء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b9868415-0ca1-46bf-a698-978593cd03a2	00000000-0000-0000-0000-000000000003	41	\N	Store	Entreposer	حفظ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7391b8f7-d9ae-459e-9c97-719cf923700c	00000000-0000-0000-0000-000000000003	41	\N	Wrap	Envelopper	لف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4bae7649-4d2c-439c-9d02-6999885aac5f	00000000-0000-0000-0000-000000000003	41	\N	Spread	Étendre	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
696179fc-1885-4427-85e6-9946df1a7611	00000000-0000-0000-0000-000000000003	41	\N	Sweat	Étuver	تبخير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3a0c5a85-2f71-4303-95e6-e46e6f974930	00000000-0000-0000-0000-000000000003	41	\N	Shape	Façonner	اعطاء شكل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
17c1a934-f27b-4db7-8cc7-331501d2bf10	00000000-0000-0000-0000-000000000003	41	\N	Stuff	Farcir	حشي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a9d995ce-3ef6-4dbf-aefc-eb7585881516	00000000-0000-0000-0000-000000000003	41	\N	Flour	Fariner	طحين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d85b1a78-d1f6-49cd-a7ee-c0300b95582a	00000000-0000-0000-0000-000000000003	41	\N	Soak	Imbiber	نقع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c35c6020-7ce5-42c9-9ae8-775acf4d1c88	00000000-0000-0000-0000-000000000003	41	\N	Incorporate	Incorporer	دمج او تجسيد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1f167592-fce0-48f4-ab06-d8dab118f616	00000000-0000-0000-0000-000000000003	41	\N	Roll	Laminer	تدحرج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e534d46b-9c5e-4100-9d73-59ab2197469f	00000000-0000-0000-0000-000000000003	41	\N	Catch	Pincer	قرص	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
92377be7-593b-4340-881f-f7f5047f0ac1	00000000-0000-0000-0000-000000000003	41	\N	Fold	Plier	طي	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5a408249-c161-4e73-a826-a43496a082f3	00000000-0000-0000-0000-000000000003	41	\N	Spray	Poudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
619bcd3c-4d6f-4326-af52-3c71438756e0	00000000-0000-0000-0000-000000000003	41	\N	Protect	Protéger	حماية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
745bdb91-19b3-42a8-b0a0-2249f4e28f18	00000000-0000-0000-0000-000000000003	41	\N	Refold	Rabattre	امالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5aae7587-5b14-4414-a43e-4dee41801bc8	00000000-0000-0000-0000-000000000003	41	\N	raise taste	Relever	رفع الطعم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b551183d-b614-4742-8fd9-1f4fe7e19192	00000000-0000-0000-0000-000000000003	41	\N	Pour	Renverser	صب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ba76e47b-f38c-401f-8e9a-a3f5be662e77	00000000-0000-0000-0000-000000000003	41	\N	Sit dough	Reposer	اراحة العجين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
67031e05-6b12-4cc3-84d0-de9269741a2b	00000000-0000-0000-0000-000000000003	41	\N	Rmove	Retirer	اخراج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
71b0b3eb-a7f7-4cbe-b87e-5133a099ffb4	00000000-0000-0000-0000-000000000003	41	\N	Sprinkle	Saupoudrer	رش	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a45fd087-030b-4a15-bf3f-23e7733e9f0e	00000000-0000-0000-0000-000000000003	41	\N	Bake	Cuire	خبز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b1ffd138-e5d2-4dfd-8a6b-c426058ebbf2	00000000-0000-0000-0000-000000000003	41	\N	Shine	Faire briller	تلميع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
eaf5ec2d-b416-4be2-a3d7-fddca1e784b5	00000000-0000-0000-0000-000000000003	41	\N	Warm up	Chauffer	الاحماء	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
79f7fb10-b0ee-4ed3-bcca-cb12a3b72f8a	00000000-0000-0000-0000-000000000003	41	\N	Get rid of	Débarrasser	ازالة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
65574b1c-61b7-4b41-962d-b17b8dc1d4a5	00000000-0000-0000-0000-000000000003	41	\N	Dry	Dessécher	تجفيف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b40556f8-43a6-4c5a-9f1e-f56740ed9a00	00000000-0000-0000-0000-000000000003	41	\N	lock	Enfermer	قفل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6dad898b-aa62-452d-9674-bfa81b134c7e	00000000-0000-0000-0000-000000000003	41	\N	Put into oven	Enfourner	وضع في الفرن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
94e65ba6-dd74-4513-bed9-b7dedba0eb2e	00000000-0000-0000-0000-000000000003	41	\N	Drop	Faire tomber	انخفاض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a66888fe-92c4-4548-ba7d-97db23e2a7f2	00000000-0000-0000-0000-000000000003	41	\N	Put	Mettre	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
24c959f3-18d6-4e46-9d0d-bab21058f2d5	00000000-0000-0000-0000-000000000003	41	\N	Follow on	Poursuivre	متابعة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3fd85f2b-97b9-41e9-8850-9ee9f2466918	00000000-0000-0000-0000-000000000003	41	\N	Rest	Reposer	اراحة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0d8f0247-efaa-4343-acd6-614d1c9d3971	00000000-0000-0000-0000-000000000003	41	\N	Take off	Retirer	خلع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
454ae584-3ade-4d6c-995f-d754726d43b7	00000000-0000-0000-0000-000000000003	41	\N	roll over	Retourner	برم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a98398d6-4de1-4404-8e73-65ae4000244f	00000000-0000-0000-0000-000000000003	41	\N	Brown	Saisir	أسمر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4a4d28c2-8932-4361-a390-4fdb93820712	00000000-0000-0000-0000-000000000003	41	\N	Finish cooking	Terminer	الانتهاء من الطبخ	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ecbc5672-cbe8-4a7c-b74e-321239f548c5	00000000-0000-0000-0000-000000000003	41	\N	Cool down	Tiédir	تبريد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
180f2539-17f3-4075-912b-4b706b294e72	00000000-0000-0000-0000-000000000003	41	\N	Sort out	Trier	فرز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c047fae8-2d62-4eb0-bc03-ec05cd9310c0	00000000-0000-0000-0000-000000000003	39	\N	Decorate	Decorer	تزيين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fcfc7205-f0b0-4de6-a256-7625d4c65cd2	00000000-0000-0000-0000-000000000003	39	\N	Finalize	Finaliser	وضع اللمسات الأخيرة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b75a23a5-a286-4842-96f6-9abac1de1156	00000000-0000-0000-0000-000000000003	39	\N	Flavor	Aromatiser	نكهة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
7903e0fc-aa7d-4b13-b49a-5b6e297c87b5	00000000-0000-0000-0000-000000000003	39	\N	Whip cream	battre de la crème	خبط الكريم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0666d99d-44b2-4c15-94be-a929a3d8b43e	00000000-0000-0000-0000-000000000003	39	\N	Boil	Bouillir	دمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8b687a8e-eaa3-4e06-a664-b5a6a4447155	00000000-0000-0000-0000-000000000003	39	\N	Warm	Chauffer	تسخين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
79019cce-b13e-425e-86f1-d1c0b226650f	00000000-0000-0000-0000-000000000003	39	\N	Stick	Coller	لصق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3ade4f3c-d46f-4409-bcf7-d7bcf617de07	00000000-0000-0000-0000-000000000003	39	\N	Color	Colorer	تلوين	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
19b94cfa-92bc-4c1b-898e-a466270a846c	00000000-0000-0000-0000-000000000003	39	\N	Crush	Concasser	طحن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b3952e94-3bbf-454f-a510-c116a9646fe2	00000000-0000-0000-0000-000000000003	39	\N	Coat	Couvrir	تغطية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4099170f-0e50-4050-9de5-38529094d8a2	00000000-0000-0000-0000-000000000003	39	\N	Pastry cone	Cornet a patisserie	المعجنات مع كورنيت	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
aec6af48-8c68-4417-8ac2-cf4a039db1f0	00000000-0000-0000-0000-000000000003	39	\N	Stone	Dénoyauter	ازالة العجو	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
24d96554-ac13-4cc8-bb2f-092304c678ab	00000000-0000-0000-0000-000000000003	39	\N	Itemize	Détailler	فصل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
df29d8dd-a4dd-424c-b7b7-cb4b379cdb16	00000000-0000-0000-0000-000000000003	39	\N	Slice	Émincer	تنعيم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2549ae79-1a34-4a0d-9ea9-c355982de1af	00000000-0000-0000-0000-000000000003	39	\N	Dessed	Épépiner	ازالة البذر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fe081bbf-8016-4e21-8906-2d62a6ae3d6e	00000000-0000-0000-0000-000000000003	39	\N	Hull	Équeuter	إزالة الهيكل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9f815a08-5698-47bd-aa23-20d39143539a	00000000-0000-0000-0000-000000000003	39	\N	Wring	Essorer	أقحام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0d367c27-1b3a-4c7c-938b-b08d40e538e3	00000000-0000-0000-0000-000000000003	39	\N	Spread	Étaler	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b1bab347-e36d-4531-8c01-706f8ebf0b6d	00000000-0000-0000-0000-000000000003	39	\N	Candy	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f7ac92d1-14aa-41a6-bb0d-3dfe107a5c51	00000000-0000-0000-0000-000000000003	39	\N	Chill	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d1f2deac-da1f-4d3c-9378-dda9d48cefc0	00000000-0000-0000-0000-000000000003	39	\N	Macerate	Macérer	نهك	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
04fc7e24-26f9-4d92-b9c3-0b4895586177	00000000-0000-0000-0000-000000000003	39	\N	Soak	Mouiller	ترطيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
99c914b9-0c1f-4af9-b40b-41bf0e93237f	00000000-0000-0000-0000-000000000003	39	\N	Expose	Présenter	تقديم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4a80c54a-05b1-4834-839a-a24ce4198d8d	00000000-0000-0000-0000-000000000003	39	\N	Turn onto	Retourner	قلب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9a970ac8-0f39-4a73-8a53-9b63cbc3fce3	00000000-0000-0000-0000-000000000003	39	\N	Split	Séparer	فصل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
28852677-7717-4564-8fd9-42db5516df97	00000000-0000-0000-0000-000000000003	42	\N	Pack	Emballer	تغليف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a5e8906d-68a3-450f-b306-14771f86b533	00000000-0000-0000-0000-000000000003	42	\N	Prepare package	Préparer emballage	تحضير التغليف	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0c49c197-f9da-44bf-993f-9d4d4939048b	00000000-0000-0000-0000-000000000003	42	\N	Open	Ouvrir	فتح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3db27605-e7ed-4310-9dae-db087d232e21	00000000-0000-0000-0000-000000000003	42	\N	Slide	Glisser	انزلاق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f9056fc4-6774-456f-a6a1-debb8ffcdbb6	00000000-0000-0000-0000-000000000003	42	\N	Wrap	Empaquetter	توضيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
db88f222-9e5f-4eea-ad8f-78b8b324139a	00000000-0000-0000-0000-000000000003	42	\N	Put sticker	Etiqueter	وضع العلامات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
373bfd6d-b769-48cd-a6a0-d51308d98b06	00000000-0000-0000-0000-000000000003	42	\N	Close	Fermer	اقفال	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
fe049fa9-7af5-4b27-b744-4a36076b2ff1	00000000-0000-0000-0000-000000000003	43	\N	Display	Exposer	عرض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
2071294f-e736-4d92-a6fc-092471fdc25e	00000000-0000-0000-0000-000000000003	43	\N	Prepare showcase	Préparer etalage	تحضير العرض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4da3ea7d-d1ca-42eb-a34b-1d6d8e3e4ede	00000000-0000-0000-0000-000000000003	43	\N	Arrange	Disposer	وضع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
dbeb2a22-04e9-47f3-a6e3-5414d47ba57b	00000000-0000-0000-0000-000000000003	43	\N	Price	Mettre les prix	وضع الأسعار	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9956a0e9-2e1f-4c60-9efc-a5ee748ce704	00000000-0000-0000-0000-000000000003	44	\N	Sell	Vendre	بيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
b7f477d6-f40f-44b3-abd0-de8ff19c91d3	00000000-0000-0000-0000-000000000003	44	\N	Greet client	Acceuillir client	استقبال الزبائن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
276a0b97-3842-470c-a4c0-79175e1b4927	00000000-0000-0000-0000-000000000003	44	\N	Advise	Conseiller	اعطاء نصائح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
07f11fd8-a107-4955-9cfb-94548407be49	00000000-0000-0000-0000-000000000003	44	\N	Close sale	Finaliser vente	الانتهاء من البيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
94b8f229-3cc6-4e63-876a-c587489d6cef	00000000-0000-0000-0000-000000000003	44	\N	Perceive amount	Encaisser	قبض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
976abcff-7801-47e7-bf81-109f8d8d64d6	00000000-0000-0000-0000-000000000003	45	\N	Management	Administration	الادارة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
8e0913d1-a4f2-47fc-8943-80a905760d3f	00000000-0000-0000-0000-000000000003	45	\N	Manage a workstation	Entretenir un poste de travail	إدارة مكان العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
63aba3fb-5d8e-4109-83bc-e3d231da5173	00000000-0000-0000-0000-000000000003	45	\N	Follow stock situation	Suivre l'état des stocks	متابعة حركة المخزن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
65d5c59d-91eb-4c54-9af6-2b2746499189	00000000-0000-0000-0000-000000000003	45	\N	Detail  supplies	Définir des besoins en approvisionnement	تفنيد الحاجات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
3910cf58-815c-45c6-8fe3-142bc48029ad	00000000-0000-0000-0000-000000000003	45	\N	Prepare orders	Préparer les commandes	تحضير الطلبات (طلبات المشتريات)	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e32d4c0b-bdb3-4ccd-a84c-5b0ddfceb1d7	00000000-0000-0000-0000-000000000003	45	\N	Manage budget	Gerer son budget	ادارة الميزانية	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
781630d0-8eeb-4f63-9718-3de081c42134	00000000-0000-0000-0000-000000000003	46	\N	Hygiene	Hygiene	النظافة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
4622feb4-ea1e-462f-9072-cfdc77ae5d2c	00000000-0000-0000-0000-000000000003	46	\N	Food hygiene	Hybgiene alimentaire	نظافة الطعام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c1afec34-decd-41c0-9acf-accbed9e2de4	00000000-0000-0000-0000-000000000003	46	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
605eef49-27d4-4eb3-a2c4-ca2d089a4449	00000000-0000-0000-0000-000000000003	46	\N	Clean area	Nettoyer l'espace	تنظيف مساحة العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
53f590aa-29fb-4ecd-b206-4651114355b3	00000000-0000-0000-0000-000000000003	46	\N	Clean tools	Nettoyer les équipements	تنظيف اواني العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
83d9d4f2-fa36-408a-a4e9-5e3c072f4878	00000000-0000-0000-0000-000000000003	46	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات والأدوات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1a96870e-beb8-49e2-b0db-1a4fd1e6345e	00000000-0000-0000-0000-000000000003	46	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6364510d-2ecb-42e9-8f47-e1c816190b48	00000000-0000-0000-0000-000000000003	34	\N	Rmove	Retirer	اخراج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
36c2cb3c-1bf7-4eee-b005-29ddea7bec47	00000000-0000-0000-0000-000000000003	47	\N	Dessed	Épépiner	ازالة البذر	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
41a6358f-09d0-4570-9050-a6cbeaf97db0	00000000-0000-0000-0000-000000000003	47	\N	Hull	Équeuter	إزالة الهيكل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ed5a398c-25ef-49cb-9a66-a35cd09fc6ae	00000000-0000-0000-0000-000000000003	47	\N	Wring	Essorer	أقحام	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
1ccce69a-4a2e-4efc-bd3b-af8c4ed75c53	00000000-0000-0000-0000-000000000003	47	\N	Spread	Étaler	مد	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
10730b18-41c1-43e5-a055-fd68a9f0bb7e	00000000-0000-0000-0000-000000000003	47	\N	Beat	Fouetter	خبط	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
548efe10-dbbf-420f-9446-12b7aee860d8	00000000-0000-0000-0000-000000000003	47	\N	Candy	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5c56bd3d-0876-4e72-b462-b02aeb13838f	00000000-0000-0000-0000-000000000003	47	\N	Chill	Glacer	تفريز	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c0957b93-d5f0-4bbc-8a85-fc79dfa72365	00000000-0000-0000-0000-000000000003	47	\N	Macerate	Macérer	نهك	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
39047c24-c2c6-43ae-a054-dc36aa805987	00000000-0000-0000-0000-000000000003	47	\N	Soak	Mouiller	ترطيب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
e40a7a34-d90e-46cc-b614-a8f2cfbb6011	00000000-0000-0000-0000-000000000003	47	\N	Coat	Napper	تطبيق	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a0477144-8011-47cc-8188-7ff43ae68e28	00000000-0000-0000-0000-000000000003	47	\N	Flavor	Parfumer	تعطير	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
5f4c9feb-f853-47ce-afcb-97c1adf9cb7d	00000000-0000-0000-0000-000000000003	47	\N	Expose	Présenter	تقديم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6fbea48f-6b60-481b-ac78-5bb01acf9ac7	00000000-0000-0000-0000-000000000003	47	\N	Rectify	Rectifier	تصحيح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
35935966-366e-4633-b14b-d08be0c9e885	00000000-0000-0000-0000-000000000003	47	\N	Turn onto	Retourner	قلب	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
155f9ede-ca7e-4ed0-bc36-a49598fe5681	00000000-0000-0000-0000-000000000003	47	\N	Split	Séparer	فصل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6a57b2eb-6dc7-421b-b584-68423d7f7685	00000000-0000-0000-0000-000000000003	47	\N	Stick	Souder	لحم	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
d289b33b-0461-4110-9cbf-a3858c2ffe23	00000000-0000-0000-0000-000000000003	47	\N	Slice	Trancher	تشريح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
ebfc1eca-0430-415c-b6d6-1ebaafed3b03	00000000-0000-0000-0000-000000000003	26	\N	Know HACCP rules & regulations	Maitriser le HACCP [regles internationales]	تطبيق قواعد و أنظمة HACCP	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
6587c963-aa20-4f51-835d-61ab0150c4c8	00000000-0000-0000-0000-000000000003	48	\N	Clean tools	Nettoyer les équipements	تنظيف اواني العمل	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a6bfa460-c021-44ef-9e5a-f9f76f33bd75	00000000-0000-0000-0000-000000000003	48	\N	Clean equipment and tools	Nettoyer du matériel ou un équipement	تنظيف المعدات والأدوات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
91bb965a-9e68-4bf0-a1c5-9adf48341abc	00000000-0000-0000-0000-000000000003	48	\N	Tidy equipment	Ranger le materiel	توضيب المعدات	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
f96f99b3-cbd5-4407-b259-c97b7fcd2799	00000000-0000-0000-0000-000000000003	37	\N	Sell	Vendre	بيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
0f2a2d12-a256-4c5d-9fa2-6fde68248472	00000000-0000-0000-0000-000000000003	37	\N	Greet client	Acceuillir client	استقبال الزبائن	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
c5c68247-5894-4ee5-9de5-070063da6cc0	00000000-0000-0000-0000-000000000003	37	\N	Advise	Conseiller	اعطاء نصائح	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
83cb2556-bdc6-400d-8257-edc1750e7a4a	00000000-0000-0000-0000-000000000003	37	\N	Close sale	Finaliser vente	الانتهاء من البيع	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
36f9135b-0499-4288-b052-c5a1e297f6ed	00000000-0000-0000-0000-000000000003	37	\N	Perceive amount	Encaisser	قبض	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
9190503c-fb9d-4a0f-8cce-05ad78160420	00000000-0000-0000-0000-000000000003	37	\N	Give back	Rendre monnaie	اعادة الفكة	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
a7553185-1ae9-4cd6-bcdc-ebf1e268b12b	00000000-0000-0000-0000-000000000003	34	\N	Take off	Retirer	اخراج	\N	f	2026-03-19 00:01:35.520931	2026-03-19 00:01:35.520931
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, role, created_at, updated_at) FROM stdin;
\.


--
-- Name: body_parts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.body_parts_id_seq', 17, true);


--
-- Name: task_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_assessments_id_seq', 21677, true);


--
-- Name: task_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_categories_id_seq', 12, true);


--
-- Name: abilities abilities_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_code_key UNIQUE (code);


--
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- Name: applications applications_candidate_id_job_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_candidate_id_job_role_id_key UNIQUE (candidate_id, job_role_id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: body_parts body_parts_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_parts
    ADD CONSTRAINT body_parts_code_key UNIQUE (code);


--
-- Name: body_parts body_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_parts
    ADD CONSTRAINT body_parts_pkey PRIMARY KEY (id);


--
-- Name: candidate_abilities candidate_abilities_candidate_id_ability_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_abilities
    ADD CONSTRAINT candidate_abilities_candidate_id_ability_id_key UNIQUE (candidate_id, ability_id);


--
-- Name: candidate_abilities candidate_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_abilities
    ADD CONSTRAINT candidate_abilities_pkey PRIMARY KEY (id);


--
-- Name: candidates candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (id);


--
-- Name: employers employers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employers
    ADD CONSTRAINT employers_pkey PRIMARY KEY (id);


--
-- Name: job_roles job_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_roles
    ADD CONSTRAINT job_roles_pkey PRIMARY KEY (id);


--
-- Name: task_assessments task_assessments_job_role_id_task_id_body_part_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments
    ADD CONSTRAINT task_assessments_job_role_id_task_id_body_part_id_key UNIQUE (job_role_id, task_id, body_part_id);


--
-- Name: task_assessments task_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments
    ADD CONSTRAINT task_assessments_pkey PRIMARY KEY (id);


--
-- Name: task_categories task_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_categories
    ADD CONSTRAINT task_categories_pkey PRIMARY KEY (id);


--
-- Name: task_requirements task_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_requirements
    ADD CONSTRAINT task_requirements_pkey PRIMARY KEY (id);


--
-- Name: task_requirements task_requirements_task_id_ability_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_requirements
    ADD CONSTRAINT task_requirements_task_id_ability_id_key UNIQUE (task_id, ability_id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


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
-- Name: idx_applications_candidate; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_candidate ON public.applications USING btree (candidate_id);


--
-- Name: idx_applications_job_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_job_role ON public.applications USING btree (job_role_id);


--
-- Name: idx_candidate_abilities_cand; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidate_abilities_cand ON public.candidate_abilities USING btree (candidate_id);


--
-- Name: idx_candidates_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidates_user_id ON public.candidates USING btree (user_id);


--
-- Name: idx_employers_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employers_user_id ON public.employers USING btree (user_id);


--
-- Name: idx_job_roles_employer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_roles_employer_id ON public.job_roles USING btree (employer_id);


--
-- Name: idx_task_assessments_body; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assessments_body ON public.task_assessments USING btree (body_part_id);


--
-- Name: idx_task_assessments_job; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assessments_job ON public.task_assessments USING btree (job_role_id);


--
-- Name: idx_task_assessments_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assessments_task ON public.task_assessments USING btree (task_id);


--
-- Name: idx_tasks_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_category_id ON public.tasks USING btree (category_id);


--
-- Name: idx_tasks_job_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_job_role_id ON public.tasks USING btree (job_role_id);


--
-- Name: abilities abilities_body_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_body_part_id_fkey FOREIGN KEY (body_part_id) REFERENCES public.body_parts(id) ON DELETE SET NULL;


--
-- Name: applications applications_candidate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id) ON DELETE CASCADE;


--
-- Name: applications applications_job_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_job_role_id_fkey FOREIGN KEY (job_role_id) REFERENCES public.job_roles(id) ON DELETE CASCADE;


--
-- Name: candidate_abilities candidate_abilities_ability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_abilities
    ADD CONSTRAINT candidate_abilities_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES public.abilities(id) ON DELETE CASCADE;


--
-- Name: candidate_abilities candidate_abilities_candidate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_abilities
    ADD CONSTRAINT candidate_abilities_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id) ON DELETE CASCADE;


--
-- Name: candidates candidates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidates
    ADD CONSTRAINT candidates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: employers employers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employers
    ADD CONSTRAINT employers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: job_roles job_roles_employer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_roles
    ADD CONSTRAINT job_roles_employer_id_fkey FOREIGN KEY (employer_id) REFERENCES public.employers(id) ON DELETE SET NULL;


--
-- Name: task_assessments task_assessments_body_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments
    ADD CONSTRAINT task_assessments_body_part_id_fkey FOREIGN KEY (body_part_id) REFERENCES public.body_parts(id) ON DELETE CASCADE;


--
-- Name: task_assessments task_assessments_job_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments
    ADD CONSTRAINT task_assessments_job_role_id_fkey FOREIGN KEY (job_role_id) REFERENCES public.job_roles(id) ON DELETE CASCADE;


--
-- Name: task_assessments task_assessments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assessments
    ADD CONSTRAINT task_assessments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_requirements task_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_requirements
    ADD CONSTRAINT task_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES public.abilities(id) ON DELETE CASCADE;


--
-- Name: task_requirements task_requirements_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_requirements
    ADD CONSTRAINT task_requirements_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.task_categories(id) ON DELETE SET NULL;


--
-- Name: tasks tasks_job_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_job_role_id_fkey FOREIGN KEY (job_role_id) REFERENCES public.job_roles(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict VeIInfPnabaSdCzNHygDFMZq9MZBATwBL1wWwvxkSQK5gn7d6xvoTHPFWKGiLnk

