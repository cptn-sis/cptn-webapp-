<template>
  <v-container>

    <v-toolbar color="primary">
      <v-toolbar-title class="white--text">Nuevo Documento</v-toolbar-title>
    </v-toolbar>

    <v-card>
        <v-form ref="form">

        <v-layout row>
            <v-flex xs12 md3 class="mx-5 mb-3 mt-4">
                <v-select
                  label="Tipo:"
                  :items="global_state.opciones.documento"
                  v-model="documento.tipo"
                  item-text="valor"
                  item-value="id"
                  :rules="[rules.required]"
                ></v-select>
            </v-flex>

            <v-flex xs12 md3 class="mx-5 mb-3" mt-4>
                <input-fecha
                    label="Fecha"
                    v-model="documento.fecha"
                    :rules="[rules.required, rules.fecha]"
                ></input-fecha>
            </v-flex>

            <v-flex xs12 md3 class="mx-5 mb-3" mt-4>
                <input-numero
                    label="N°"
                    v-model="documento.numero"
                    maxlength="9"
                    :rules="[rules.required, rules.number]"
                ></input-numero>
            </v-flex>
        </v-layout>
        </v-form>

        <v-layout>
            <v-flex xs12 md6 class="mx-5">
                <span class="mr-4">Archivo:</span>
                <input type="file" name="archivo" id="archivo" ref="archivo">
            </v-flex>
        </v-layout>

        <v-layout>
            <v-flex xs12 class="ma-5">
                <v-btn
                    class="green darken-1 white--text right"
                    @click.native="submit"
                    :disabled="submitted"
                    :loading="submitted"
                >
                    Guardar
                    <v-icon dark right>check_circle</v-icon>
                </v-btn>

                <v-btn dark class="red right" @click="$router.go(-1)">
                    Cancelar
                    <v-icon dark right>block</v-icon>
                </v-btn>
            </v-flex>
        </v-layout>
    </v-card>

  </v-container>
</template>

<script>
import api from '@/services/api'
import { getFecha } from '@/utils'
import MixinValidator from '@/components/mixins/MixinValidator'
import MixinGlobalState from '@/components/mixins/MixinGlobalState'
import Documento from '@/model/Documento'
import InputNumero from '@/components/base/InputNumero'
import InputFecha from '@/components/base/InputFecha'


export default {
    name: 'DocumentoNuevo',
    props: ['id'],

    mixins: [MixinGlobalState, MixinValidator],

    components: {
        InputNumero,
        InputFecha
    },

    data() {
        return {
            documento: new Documento(),
            submitted: false
        }
    },

    watch: {
        '$route' (to, from) {
            if (!this.id) { 
                this.documento = new Documento();
                this.$refs.form.reset();
            }
            else this.initDocumento();
        }
    },    

    created: function() {
        if (this.id) {
            return this.initDocumento()
        }
    },

    methods: {
        initDocumento: function() {
            return api.get(`/documentos/${this.id}`)
            .then(r => {
                this.documento.tipo = r.data.tipo.id;
                this.documento.numero = r.data.numero;
                this.documento.fecha = getFecha(r.data.fecha);
            });
        },
        submit: function() {            
            if (this.$refs.form.validate()) {
                this.submitted = true;
                let fd = new FormData();
                for(let att in this.documento) fd.append(att, this.documento[att]);
                fd.append('archivo', this.$refs.archivo.files[0]);

                if (this.id) {
                    api.put(`/documentos/${this.id}`, fd)
                    .then(r => {
                        this.snackOk('Documento actualizado exitosamente!');
                        this.submitted = false;
                        this.documento = new Documento();                        
                        this.$router.go(-1);
                    })
                    .catch(e => {
                        this.submitted = false;
                        this.snackError(e);
                    })
                }
                else {
                    api.post('/documentos', fd)
                    .then(r => {
                        this.snackOk('Documento creado exitosamente!');
                        this.submitted = false;
                        this.documento = new Documento();
                        this.$router.replace('/documentos/lista');
                    })
                    .catch(e => {
                        this.submitted = false;
                        this.snackError(e);
                    })
                }
            }
        }
    }

}
</script>

<style>

</style>
