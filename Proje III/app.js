var express = require('express');
var path = require('path');
var logger = require('morgan');
var bodyParser = require('body-parser');
var neo4j = require('neo4j-driver');
var xml2js = require('xml2js');
var parser = xml2js.Parser();
const https = require('https');

var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

var driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j', '123456'));
var session = driver.session();

app.get('/', function (req, res) {
    res.render('index');
});

app.get('/parse', async function (req, res) {
    if (typeof (req.query.data) != 'undefined') {
        var xml;
        let request = https.get(req.query.data, function (response) {
            let data = '';
            response.on('data', function (stream) {
                data += stream;
            });
            response.on('end', function () {
                parser.parseString(data, function (error, result) {
                    if (error === null) {
                        xml = result;
                    }
                    else {
                        console.log(error);
                    }
                    saveData(xml);
                    res.render('parse', {
                        success: true
                    });
                });
            });
        });
    } else {
        res.render('parse');
    }

});

app.get('/arastirmaci', async function (req, res) {
    var yayinlar = [];
    var yazarlar = [];
    var turler = [];
    var ortaklar = [];

    var arastirmaci = await session
        .run('MATCH (a:Arastirmaci) WHERE a.pid=$pid RETURN a', { pid: req.query.pid });
    var name = arastirmaci.records[0]._fields[0].properties.adi_soyadi

    session
        .run('MATCH (a:Arastirmaci)-[:Yazar]->(yayin) WHERE a.pid=$pid RETURN yayin', { pid: req.query.pid })
        .then(async function (result) {
            result.records.forEach(function (record) {
                yayinlar.push({
                    id: record._fields[0].identity.low,
                    adi: record._fields[0].properties.adi,
                    tarih: record._fields[0].properties.tarih,
                    yer: record._fields[0].properties.yer
                });
            });

            if (yayinlar.length != 0) {
                for (var i = 0; i < yayinlar.length; i++) {
                    var r = await session
                        .run('MATCH (a:Arastirmaci)-->(yayin) WHERE id(yayin)=$id RETURN a', { id: yayinlar[i].id });
                    var results = r.records;
                    var list = [];
                    results.forEach(function (y) {
                        list.push({
                            id: y._fields[0].identity.low,
                            adi_soyadi: y._fields[0].properties.adi_soyadi,
                            pid: y._fields[0].properties.pid,
                        });
                    });
                    yazarlar.push(list);
                }

                for (var i = 0; i < yayinlar.length; i++) {
                    var r = await session
                        .run('MATCH (y:Yayin)-->(tur) WHERE id(y)=$id RETURN tur', { id: yayinlar[i].id });
                    var results = r.records;
                    results.forEach(function (y) {
                        turler.push({
                            adi: y._fields[0].properties.adi,
                        });
                    });
                }

                var r = await session
                        .run('MATCH (n:Arastirmaci)<-[r:Ortak]->(m:Arastirmaci) WHERE n.pid = $pid RETURN *', { pid: req.query.pid });
                    var results = r.records;
                    results.forEach(function (y) {
                        ortaklar.push({
                            id: y._fields[0].identity.low,
                            adi_soyadi: y._fields[0].properties.adi_soyadi,
                            pid: y._fields[0].properties.pid,
                        });
                    });
            }

            res.render('details', {
                name: name,
                yayinlar: yayinlar,
                yazarlar: yazarlar,
                turler: turler,
                ortaklar: ortaklar
            });
        })
        .catch(function (error) {
            console.log(error);
        });
});

async function saveData(xml) {
    await session
        .run('MERGE(n:Arastirmaci {pid:$pid, adi_soyadi:$adi_soyadi} )', { pid: xml.dblpperson.$.pid, adi_soyadi: xml.dblpperson.$.name });

    for (var i = 0; i < xml.dblpperson.coauthors[0].co.length; i++) {
        var author = xml.dblpperson.coauthors[0].co[i].na[0];
        await session
            .run('MERGE(n:Arastirmaci {pid:$pid, adi_soyadi:$adi_soyadi} )', { pid: author.$.pid, adi_soyadi: author._ });
    }

    for (var i = 0; i < xml.dblpperson.r.length; i++) {
        var yayin;
        if (typeof (xml.dblpperson.r[i].article) != 'undefined') {
            yayin = xml.dblpperson.r[i].article[0];
            yayin.tur = "Makale";
            yayin.yer = yayin.journal[0]
        } else if (typeof (xml.dblpperson.r[i].inproceedings) != 'undefined') {
            yayin = xml.dblpperson.r[i].inproceedings[0];
            yayin.tur = "Bildiri";
            yayin.yer = "Belirtilmemis"
        }

        if (typeof (yayin.title[0]._) != 'undefined') {
            yayin.title[0] = yayin.title[0].i + yayin.title[0]._;
        }

        await session
            .run('MERGE(n:Yayin {key:$key, adi:$adi, tarih:$tarih, yer:$yer} )', { key: yayin.$.key, adi: yayin.title[0], tarih: yayin.year[0], yer: yayin.yer });

        await session
            .run('MATCH (t:Tur {adi:$adi}), (yayin:Yayin {key:$key}) MERGE (yayin)-[:Tur]->(t)', { adi: yayin.tur, key: yayin.$.key });

        for (var j = 0; j < yayin.author.length; j++) {
            var author = yayin.author[j];
            await session
                .run('MATCH (a:Arastirmaci {pid:$pid}), (yayin:Yayin {key:$key}) MERGE (a)-[:Yazar]->(yayin)', { key: yayin.$.key, pid: author.$.pid });
        }

        for (var j = 0; j < yayin.author.length; j++) {
            var author = yayin.author[j];
            await session
                .run('MATCH (a:Arastirmaci {pid:$pid1}), (b:Arastirmaci {pid:$pid2}) WHERE a.adi_soyadi <> b.adi_soyadi MERGE (a)<-[:Ortak]->(b)', { pid1: xml.dblpperson.$.pid, pid2: author.$.pid });
        }
    }
}

app.get('/login', function (req, res) {
    var error = req.query.error;
    res.render('login', {
        error: error
    });
});

app.post('/login', async function (req, res) {
    var nick = req.body.username;
    var pass = req.body.password;

    var result = await session.run('MATCH(n:User {kullaniciAdi: $nick, sifre: $pass}) RETURN n', { pass: pass, nick: nick });
    if (result.records.length != 0) {
        res.redirect('/parse');
    } else {
        res.redirect('/login?error=true');
    }
});

app.get('/results', function (req, res) {
    var value = req.query.search;
    var arr = [];
    var yayinlar = [];
    var yazarlar = [];
    var turler = [];

    session
        .run('MATCH(n:Arastirmaci) WHERE LOWER(n.adi_soyadi) CONTAINS $search RETURN n', { search: value.toLowerCase() })
        .then(function (result) {
            result.records.forEach(function (record) {
                arr.push({
                    id: record._fields[0].identity.low,
                    adi_soyadi: record._fields[0].properties.adi_soyadi,
                    pid: record._fields[0].properties.pid,
                });
            });

            session
                .run('MATCH(n:Yayin) WHERE LOWER(n.adi) CONTAINS $search OR n.tarih CONTAINS $search RETURN n', { search: value.toLowerCase() })
                .then(async function (result) {
                    result.records.forEach(function (record) {
                        yayinlar.push({
                            id: record._fields[0].identity.low,
                            adi: record._fields[0].properties.adi,
                            yer: record._fields[0].properties.yer,
                            tarih: record._fields[0].properties.tarih,
                        });
                    });

                    if (yayinlar.length != 0) {
                        for (var i = 0; i < yayinlar.length; i++) {
                            var r = await session
                                .run('MATCH (a:Arastirmaci)-->(yayin) WHERE id(yayin)=$id RETURN a', { id: yayinlar[i].id });
                            var results = r.records;
                            var list = [];
                            results.forEach(function (y) {
                                list.push({
                                    id: y._fields[0].identity.low,
                                    adi_soyadi: y._fields[0].properties.adi_soyadi,
                                    pid: y._fields[0].properties.pid,
                                });
                            });
                            yazarlar.push(list);
                        }

                        for (var i = 0; i < yayinlar.length; i++) {
                            var r = await session
                                .run('MATCH (y:Yayin)-->(tur) WHERE id(y)=$id RETURN tur', { id: yayinlar[i].id });
                            var results = r.records;
                            results.forEach(function (y) {
                                turler.push({
                                    adi: y._fields[0].properties.adi,
                                });
                            });
                        }
                    }
                    res.render('results', {
                        arastirmacilar: arr,
                        input: value,
                        yayinlar: yayinlar,
                        yazarlar: yazarlar,
                        turler: turler
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        })
        .catch(function (error) {
            console.log(error);
        });

})

app.listen(3000);
console.log('Server Started');

module.exports = app;
