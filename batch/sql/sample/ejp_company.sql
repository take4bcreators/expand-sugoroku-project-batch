CREATE TABLE :schema.ejp_company (
     company_cd INTEGER,
     rr_cd INTEGER NOT NULL,
     company_name TEXT NOT NULL,
     company_name_k TEXT,
     company_name_h TEXT,
     company_name_r TEXT,
     company_url TEXT,
     company_type INTEGER,
     e_status INTEGER,
     e_sort INTEGER,
     updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY(company_cd)
);
