import 'package:isar/isar.dart';

part 'assigment_model.g.dart';

enum AssigmentType {
  projectOrder,        // PRY
  serviceProject,      // PRS
  projectAdditional,   // PRD
  warrantyProject,     // PRG
  emergency,           // EMG
  technicalVisit,      // VST
  officeAssistance,    // ASISTENCIA OFICINA
  transfer,            // TRASLADO
  other,               // OTR
}


@collection
class AssigmentModel {

  Id id = Isar.autoIncrement;
  
  @Index()
  int? serverId;

  String? documentId;
  String? client;
  String? description;
 

  @enumerated
  AssigmentType assigmentType = AssigmentType.projectOrder;

  DateTime updatedAt = DateTime.now();

    AssigmentModel({
      this.serverId,
      this.documentId,
      this.client,
      this.description,
      this.assigmentType = AssigmentType.projectOrder,
    });



  AssigmentModel.fromJson(Map<String, dynamic> json) {
    
    
    serverId = json['Identifier'];
    
    final document = (json['Document'] ?? '') as String;
    documentId = document;
    client = json['Client'];
    description = json['Description'];

    final prefix = document.length >= 3 ? document.substring(0, 3) : '';
    assigmentType = AssigmentTypeX.fromCode(prefix);

    
  }
}

extension AssigmentTypeX on AssigmentType {
  String get code {
    switch (this) {
      case AssigmentType.projectOrder: return 'PRY';
      case AssigmentType.serviceProject: return 'PRS';
      case AssigmentType.projectAdditional: return 'PRD';
      case AssigmentType.warrantyProject: return 'PRG';
      case AssigmentType.emergency: return 'EMG';
      case AssigmentType.technicalVisit: return 'VST';
      case AssigmentType.officeAssistance: return 'ASO';
      case AssigmentType.transfer: return 'TRA';
      case AssigmentType.other: return 'OTR';
    }
  }

  static AssigmentType fromCode(String? code) {
    final c = (code ?? '').toUpperCase().trim();
    switch (c) {
      case 'PRY': return AssigmentType.projectOrder;
      case 'PRS': return AssigmentType.serviceProject;
      case 'PRD': return AssigmentType.projectAdditional;
      case 'PRG': return AssigmentType.warrantyProject;
      case 'EMG': return AssigmentType.emergency;
      case 'VST': return AssigmentType.technicalVisit;
      case 'ASO': return AssigmentType.officeAssistance;
      case 'TRA': return AssigmentType.transfer;
      case 'OTR': return AssigmentType.other;
      default: return AssigmentType.other;
    }
  }

  String get label {
    switch (this) {
      case AssigmentType.projectOrder: return 'Orden de proyecto';
      case AssigmentType.serviceProject: return 'Proyecto de servicio';
      case AssigmentType.projectAdditional: return 'Proyecto adicional';
      case AssigmentType.warrantyProject: return 'Garantía';
      case AssigmentType.emergency: return 'Emergencia';
      case AssigmentType.technicalVisit: return 'Visita técnica';
      case AssigmentType.officeAssistance: return 'Asistencia oficina';
      case AssigmentType.transfer: return 'Traslado';
      case AssigmentType.other: return 'Otro';
    }
  }
}