//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Formulario
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Formulario()
        {
            this.Conformado_Item_Sec_Form = new HashSet<Conformado_Item_Sec_Form>();
            this.Formulario_Respuesta = new HashSet<Formulario_Respuesta>();
            this.Tiene_Grupo_Formulario = new HashSet<Tiene_Grupo_Formulario>();
        }
    
        public string CodigoFormulario { get; set; }
        public string Nombre { get; set; }
        public string CodigoUnidadAca { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Conformado_Item_Sec_Form> Conformado_Item_Sec_Form { get; set; }
        public virtual Unidad_Academica Unidad_Academica { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Formulario_Respuesta> Formulario_Respuesta { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Tiene_Grupo_Formulario> Tiene_Grupo_Formulario { get; set; }
    }
}
