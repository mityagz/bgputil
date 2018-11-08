--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: bgpf; Type: DATABASE; Schema: -; Owner: bgpf
--

CREATE DATABASE bgpf WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII';


ALTER DATABASE bgpf OWNER TO bgpf;

\connect bgpf

SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

--
-- Name: id_af_seq; Type: SEQUENCE; Schema: public; Owner: bgpf
--

CREATE SEQUENCE id_af_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.id_af_seq OWNER TO bgpf;

--
-- Name: id_af_seq; Type: SEQUENCE SET; Schema: public; Owner: bgpf
--

SELECT pg_catalog.setval('id_af_seq', 4, true);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bgp_af; Type: TABLE; Schema: public; Owner: bgpf; Tablespace: 
--

CREATE TABLE bgp_af (
    id integer DEFAULT nextval('id_af_seq'::regclass) NOT NULL,
    af character varying(16)
);


ALTER TABLE public.bgp_af OWNER TO bgpf;

--
-- Name: id_hn_router_seq; Type: SEQUENCE; Schema: public; Owner: bgpf
--

CREATE SEQUENCE id_hn_router_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.id_hn_router_seq OWNER TO bgpf;

--
-- Name: id_hn_router_seq; Type: SEQUENCE SET; Schema: public; Owner: bgpf
--

SELECT pg_catalog.setval('id_hn_router_seq', 6, true);


--
-- Name: bgp_hn_router; Type: TABLE; Schema: public; Owner: bgpf; Tablespace: 
--

CREATE TABLE bgp_hn_router (
    id integer DEFAULT nextval('id_hn_router_seq'::regclass) NOT NULL,
    hn_router character varying(16),
    descr character varying(256),
    "location" character varying(256)
);


ALTER TABLE public.bgp_hn_router OWNER TO bgpf;

--
-- Name: id_peer_seq; Type: SEQUENCE; Schema: public; Owner: bgpf
--

CREATE SEQUENCE id_peer_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.id_peer_seq OWNER TO bgpf;

--
-- Name: id_peer_seq; Type: SEQUENCE SET; Schema: public; Owner: bgpf
--

SELECT pg_catalog.setval('id_peer_seq', 17, true);


--
-- Name: bgp_p; Type: TABLE; Schema: public; Owner: bgpf; Tablespace: 
--

CREATE TABLE bgp_p (
    id integer DEFAULT nextval('id_peer_seq'::regclass) NOT NULL,
    peer_name character varying(256),
    type_id integer,
    hn_router_id integer,
    local_as character varying(15),
    af_id integer,
    inet_rtr character varying(15),
    ifaddr character varying(15),
    netmask character varying(15),
    aut_num character varying(15),
    as_name character varying(32),
    as_set character varying(32),
    as_path_list_num character varying(15),
    nn character varying(15),
    route_type_id integer,
    description character varying(256),
    "location" character varying(256),
    contact character varying(256)
);


ALTER TABLE public.bgp_p OWNER TO bgpf;

--
-- Name: id_route_type_seq; Type: SEQUENCE; Schema: public; Owner: bgpf
--

CREATE SEQUENCE id_route_type_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.id_route_type_seq OWNER TO bgpf;

--
-- Name: id_route_type_seq; Type: SEQUENCE SET; Schema: public; Owner: bgpf
--

SELECT pg_catalog.setval('id_route_type_seq', 4, true);


--
-- Name: bgp_route_type; Type: TABLE; Schema: public; Owner: bgpf; Tablespace: 
--

CREATE TABLE bgp_route_type (
    id integer DEFAULT nextval('id_route_type_seq'::regclass) NOT NULL,
    route_type character varying(15),
    description character varying(256)
);


ALTER TABLE public.bgp_route_type OWNER TO bgpf;

--
-- Name: id_type_seq; Type: SEQUENCE; Schema: public; Owner: bgpf
--

CREATE SEQUENCE id_type_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.id_type_seq OWNER TO bgpf;

--
-- Name: id_type_seq; Type: SEQUENCE SET; Schema: public; Owner: bgpf
--

SELECT pg_catalog.setval('id_type_seq', 4, true);


--
-- Name: bgp_type; Type: TABLE; Schema: public; Owner: bgpf; Tablespace: 
--

CREATE TABLE bgp_type (
    id integer DEFAULT nextval('id_type_seq'::regclass) NOT NULL,
    "type" character varying(16)
);


ALTER TABLE public.bgp_type OWNER TO bgpf;

--
-- Data for Name: bgp_af; Type: TABLE DATA; Schema: public; Owner: bgpf
--

COPY bgp_af (id, af) FROM stdin;
1	ipv4
2	ipv6
3	vpnv4
4	vpnv6
\.


--
-- Data for Name: bgp_hn_router; Type: TABLE DATA; Schema: public; Owner: bgpf
--

COPY bgp_route_type (id, route_type, description) FROM stdin;
1	FR	Full Route Table (Full View)
2	DFR	Default Route +  Customer Routes
4	Dummy	For Peer or Upstream
\.


--
-- Data for Name: bgp_type; Type: TABLE DATA; Schema: public; Owner: bgpf
--

COPY bgp_type (id, "type") FROM stdin;
1	Upstream
2	Peer
3	Customer
4	LocalCustomer
\.


--
-- Name: bgp_af_pkey; Type: CONSTRAINT; Schema: public; Owner: bgpf; Tablespace: 
--

ALTER TABLE ONLY bgp_af
    ADD CONSTRAINT bgp_af_pkey PRIMARY KEY (id);


--
-- Name: bgp_hn_router_pkey; Type: CONSTRAINT; Schema: public; Owner: bgpf; Tablespace: 
--

ALTER TABLE ONLY bgp_hn_router
    ADD CONSTRAINT bgp_hn_router_pkey PRIMARY KEY (id);


--
-- Name: bgp_p_pkey; Type: CONSTRAINT; Schema: public; Owner: bgpf; Tablespace: 
--

ALTER TABLE ONLY bgp_p
    ADD CONSTRAINT bgp_p_pkey PRIMARY KEY (id);


--
-- Name: bgp_route_type_pkey; Type: CONSTRAINT; Schema: public; Owner: bgpf; Tablespace: 
--

ALTER TABLE ONLY bgp_route_type
    ADD CONSTRAINT bgp_route_type_pkey PRIMARY KEY (id);


--
-- Name: bgp_type_pkey; Type: CONSTRAINT; Schema: public; Owner: bgpf; Tablespace: 
--

ALTER TABLE ONLY bgp_type
    ADD CONSTRAINT bgp_type_pkey PRIMARY KEY (id);


--
-- Name: bgp_p_af_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bgpf
--

ALTER TABLE ONLY bgp_p
    ADD CONSTRAINT bgp_p_af_id_fkey FOREIGN KEY (af_id) REFERENCES bgp_af(id);


--
-- Name: bgp_p_hn_router_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bgpf
--

ALTER TABLE ONLY bgp_p
    ADD CONSTRAINT bgp_p_hn_router_id_fkey FOREIGN KEY (hn_router_id) REFERENCES bgp_hn_router(id);


--
-- Name: bgp_p_route_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bgpf
--

ALTER TABLE ONLY bgp_p
    ADD CONSTRAINT bgp_p_route_type_id_fkey FOREIGN KEY (route_type_id) REFERENCES bgp_route_type(id);


--
-- Name: bgp_p_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bgpf
--

ALTER TABLE ONLY bgp_p
    ADD CONSTRAINT bgp_p_type_id_fkey FOREIGN KEY (type_id) REFERENCES bgp_type(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: bgp_af; Type: ACL; Schema: public; Owner: bgpf
--

REVOKE ALL ON TABLE bgp_af FROM PUBLIC;
REVOKE ALL ON TABLE bgp_af FROM bgpf;
GRANT ALL ON TABLE bgp_af TO bgpf;
GRANT ALL ON TABLE bgp_af TO mitya;


--
-- Name: bgp_hn_router; Type: ACL; Schema: public; Owner: bgpf
--

REVOKE ALL ON TABLE bgp_hn_router FROM PUBLIC;
REVOKE ALL ON TABLE bgp_hn_router FROM bgpf;
GRANT ALL ON TABLE bgp_hn_router TO bgpf;
GRANT ALL ON TABLE bgp_hn_router TO mitya;


--
-- Name: bgp_p; Type: ACL; Schema: public; Owner: bgpf
--

REVOKE ALL ON TABLE bgp_p FROM PUBLIC;
REVOKE ALL ON TABLE bgp_p FROM bgpf;
GRANT ALL ON TABLE bgp_p TO bgpf;
GRANT ALL ON TABLE bgp_p TO mitya;


--
-- Name: bgp_route_type; Type: ACL; Schema: public; Owner: bgpf
--

REVOKE ALL ON TABLE bgp_route_type FROM PUBLIC;
REVOKE ALL ON TABLE bgp_route_type FROM bgpf;
GRANT ALL ON TABLE bgp_route_type TO bgpf;
GRANT ALL ON TABLE bgp_route_type TO mitya;


--
-- Name: bgp_type; Type: ACL; Schema: public; Owner: bgpf
--

REVOKE ALL ON TABLE bgp_type FROM PUBLIC;
REVOKE ALL ON TABLE bgp_type FROM bgpf;
GRANT ALL ON TABLE bgp_type TO bgpf;
GRANT ALL ON TABLE bgp_type TO mitya;


--
-- PostgreSQL database dump complete
--

