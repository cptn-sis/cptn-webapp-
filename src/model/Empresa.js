import { Domicilio } from '@/model/Domicilio';

export class Empresa {
  constructor() {
    this.tipo = 'empresa';
    this.nombre = '';
    this.cuit = '';
    this.condafip = '';
    this.fechaInicio = null;
    this.fechaConstitucion = null;
    this.tipoEmpresa = '';
    this.tipoSociedad = '';
    this.domicilioReal = new Domicilio();
    this.domicilioLegal = new Domicilio();
    this.contactos = [];
    this.incumbencias = [];
  }
}